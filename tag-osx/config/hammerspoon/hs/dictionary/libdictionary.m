@import LuaSkin;

static int refTable = LUA_NOREF;

typedef CFTypeRef DCSRecordRef;

typedef NS_ENUM(NSUInteger, DCSDictionarySearchMethod) {
    DCSDictionarySearchMethodExactMatch,
    DCSDictionarySearchMethodPrefixMatch,
    DCSDictionarySearchMethodCommonPrefixMatch,
    DCSDictionarySearchMethodWildcardMatch
};

typedef NS_ENUM(NSUInteger, DCSDefinitionStyle) {
    DCSDefinitionStyleBareXHTML,
    DCSDefinitionStyleXHTMLForApp,
    DCSDefinitionStyleXHTMLForPanel,
    DCSDefinitionStylePlainText,
    DCSDefinitionStyleRaw
};

extern NSArray * DCSCopyAvailableDictionaries(void) NS_RETURNS_RETAINED;
extern NSArray * DCSGetActiveDictionaries(void);
extern DCSDictionaryRef DCSGetDefaultDictionary(void);
extern DCSDictionaryRef DCSGetDefaultThesaurus(void);
extern DCSDictionaryRef __nullable DCSDictionaryCreateWithIdentifier(NSString *identifier);
extern NSString * DCSDictionaryGetName(DCSDictionaryRef dictionary);
extern NSString * DCSDictionaryGetShortName(DCSDictionaryRef dictionary);
extern NSString * DCSDictionaryGetIdentifier(DCSDictionaryRef dictionary);
extern NSString * __nullable DCSDictionaryGetPrimaryLanguage(DCSDictionaryRef dictionary);
extern NSURL * __nullable DCSDictionaryGetURL(DCSDictionaryRef dictionary);

extern NSArray * __nullable DCSCopyRecordsForSearchString(DCSDictionaryRef dictionary, NSString * string, DCSDictionarySearchMethod searchMethod, NSUInteger maxResults) NS_RETURNS_RETAINED;
extern NSString * __nullable DCSRecordCopyDefinition(DCSRecordRef record, DCSDefinitionStyle format) NS_RETURNS_RETAINED;
extern NSString * __nullable DCSRecordGetHeadword(DCSRecordRef record);
extern NSString * __nullable DCSRecordGetTitle(DCSRecordRef record);

static DCSDictionaryRef findDictionaryByName(NSString *dictionaryName) {
  for (id dictId in DCSCopyAvailableDictionaries()) {
    DCSDictionaryRef dictionary = (__bridge DCSDictionaryRef) dictId;

    NSString *name = DCSDictionaryGetName(dictionary);
    if ([name isEqualToString:dictionaryName]) {
      return dictionary;
    }
  }
  return NULL;
}

/// hs.dictionary.dictionaries([all])
/// Function
/// Returns the names of dictionaries enabled for the user or available in Mac OS
///
/// Parameters:
///  * all - an optional boolean. If true, all available dictionaries will be returned. Defaults to false.
///
/// Returns:
///  * A table with the names, ids, and some other attributes of the dictionaries
static int dictionaries(lua_State *L) {
  LuaSkin *skin = [LuaSkin sharedWithState:L];
  [skin checkArgs:LS_TBOOLEAN|LS_TOPTIONAL, LS_TBREAK];

  NSArray *dictionaries;

  if (lua_isboolean(L, 1) && lua_toboolean(L, 1)) {
    dictionaries = DCSCopyAvailableDictionaries();
  } else {
    dictionaries = DCSGetActiveDictionaries();
  }

  lua_newtable(L);
  unsigned long i = 1;
  for (id dictId in dictionaries) {
    DCSDictionaryRef dictionary = (__bridge DCSDictionaryRef) dictId;

    lua_pushinteger(L, (lua_Integer)i++);
    lua_newtable(L);

    [skin pushNSObject:DCSDictionaryGetIdentifier(dictionary)];
    lua_setfield(L, -2, "id");
    [skin pushNSObject:DCSDictionaryGetName(dictionary)];
    lua_setfield(L, -2, "name");
    [skin pushNSObject:DCSDictionaryGetShortName(dictionary)];
    lua_setfield(L, -2, "shortName");
    [skin pushNSObject:DCSDictionaryGetPrimaryLanguage(dictionary)];
    lua_setfield(L, -2, "language");

    NSURL *URL = DCSDictionaryGetURL(dictionary);
    lua_pushstring(L, [URL fileSystemRepresentation]);
    lua_setfield(L, -2, "path");

    lua_settable(L, -3);
  }

  return 1;
}

/// hs.dictionary.lookup(word, dictionary, format, matching, maxResults)
/// Function
/// Lookup the definition of a word in the MacOS Dictionary
///
/// Parameters:
///  * word - The word to look up
///  * dictionary - The id or name of a dictionary or one of the keywords "active", "all", "defaultDictionary", or "defaultThesaurus".
///  * format - A number (0-3) identifying the format to be used for the definitions
///  * matching - A number (0-3) identifying the method for matching the keyword
///  * maxResults - Maximum number of results per dictionary
///
/// Returns:
///  * A table with the definitions of the word according to the selected dictionaries
static int lookup(lua_State *L) {
  LuaSkin *skin = [LuaSkin sharedWithState:L];
  [skin checkArgs:LS_TSTRING, LS_TSTRING, LS_TNUMBER, LS_TNUMBER, LS_TNUMBER, LS_TBREAK];

  NSString *word = [skin toNSObjectAtIndex:1];
  NSArray *dictionaries;
  DCSDefinitionStyle format = (DCSDefinitionStyle)lua_tointeger(L, 3);
  DCSDictionarySearchMethod matching = (DCSDictionarySearchMethod)lua_tointeger(L, 4);
  NSUInteger maxResults = lua_tointeger(L, 4);

  NSString *dictionaryName = [skin toNSObjectAtIndex:2];
  if ([dictionaryName isEqualToString:@"all"]) {
    dictionaries = DCSCopyAvailableDictionaries();
  } else if ([dictionaryName isEqualToString:@"active"]) {
    dictionaries = DCSGetActiveDictionaries();
  } else if ([dictionaryName isEqualToString:@"defaultDictionary"]) {
    dictionaries = @[(__bridge id) DCSGetDefaultDictionary()];
  } else if ([dictionaryName isEqualToString:@"defaultThesaurus"]) {
    dictionaries = @[(__bridge id) DCSGetDefaultThesaurus()];
  } else {
    DCSDictionaryRef dictionary;
    if ([dictionaryName hasPrefix:@"com.apple."]) {
      dictionary = DCSDictionaryCreateWithIdentifier(dictionaryName);
    } else {
      dictionary = findDictionaryByName(dictionaryName);
    }
    if (!dictionary) {
      return luaL_error(L, "Couldn't find dictionary '%s'", [dictionaryName UTF8String]);
    } else {
      dictionaries = @[(__bridge id) dictionary];
    }
  }

  lua_newtable(L);

  long i = 1;
  for (id dictId in dictionaries) {
    DCSDictionaryRef dictionary = (__bridge DCSDictionaryRef) dictId;

    NSArray *records = DCSCopyRecordsForSearchString(dictionary, word, matching, maxResults);
    if (records) {
      NSString *dictionaryName = DCSDictionaryGetName(dictionary);
      for (id recordId in records) {
        DCSRecordRef record = (__bridge DCSRecordRef) recordId;

        lua_pushinteger(L, (lua_Integer)i++);
        lua_newtable(L);

        [skin pushNSObject:DCSRecordCopyDefinition(record, format)];
        lua_setfield(L, -2, "definition");
        [skin pushNSObject:DCSRecordGetHeadword(record)];
        lua_setfield(L, -2, "headword");
        [skin pushNSObject:DCSRecordGetTitle(record)];
        lua_setfield(L, -2, "title");

        [skin pushNSObject:dictionaryName];
        lua_setfield(L, -2, "dictionary");

        lua_settable(L, -3);
      }
    }
  }

  return 1;
}

static luaL_Reg dictionarylib[] = {
  {"dictionaries", dictionaries},
  {"lookup", lookup},
  {NULL, NULL}
};

int luaopen_hs_libdictionary(lua_State* L) {
  LuaSkin *skin = [LuaSkin sharedWithState:L];
  refTable = [skin registerLibrary:"hs.dictionary" functions:dictionarylib metaFunctions:nil];

  return 1;
}

@import LuaSkin;

static int refTable = LUA_NOREF;

extern CFArrayRef DCSCopyAvailableDictionaries();
extern CFArrayRef DCSGetActiveDictionaries(void);
extern DCSDictionaryRef DCSGetDefaultThesaurus(void);
extern DCSDictionaryRef DCSGetDefaultDictionary(void);
extern CFStringRef DCSDictionaryGetName(DCSDictionaryRef dictionary);

extern CFArrayRef DCSCopyRecordsForSearchString(DCSDictionaryRef dictionary, CFStringRef string, void *, void *);
extern CFStringRef DCSRecordCopyData(CFTypeRef record, long version);
extern CFStringRef DCSRecordGetHeadword(CFTypeRef record);
extern CFStringRef DCSRecordGetTitle(CFTypeRef record);

DCSDictionaryRef findDictionaryByName(NSString *dictionaryName) {
  for (id dict in (__bridge_transfer NSArray *)DCSCopyAvailableDictionaries()) {
    NSString *name = (__bridge NSString *)DCSDictionaryGetName((__bridge DCSDictionaryRef) dict);
    if ([name isEqualToString:dictionaryName]) {
      return (__bridge DCSDictionaryRef) dict;
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
///  * A table with the names of the dictionaries
static int dictionaries(lua_State *L) {
  LuaSkin *skin = [LuaSkin sharedWithState:L];
  [skin checkArgs:LS_TBOOLEAN|LS_TOPTIONAL, LS_TBREAK];

  NSArray *dictionaries;

  if (lua_isboolean(L, 1) && lua_toboolean(L, 1)) {
    dictionaries = (__bridge_transfer NSArray *)DCSCopyAvailableDictionaries();
  } else {
    dictionaries = (__bridge NSArray *)DCSGetActiveDictionaries();
  }

  lua_newtable(L);
  unsigned long i = 1;
  for (id dictionary in dictionaries) {
    lua_pushinteger(L, (lua_Integer)i++);
    NSString *name = (__bridge NSString *)DCSDictionaryGetName((__bridge DCSDictionaryRef) dictionary);
    [skin pushNSObject:name];
    lua_settable(L, -3);
  }

  return 1;
}

/// hs.dictionary.lookup(word, dictionary, version)
/// Function
/// Lookup the definition of a word in the MacOS Dictionary
///
/// Parameters:
///  * word - The word to look up
///  * dictionary - The name of a dictionary or one of the keywords "active", "all", "defaultDictionary", or "defaultThesaurus".
///  * version - A number (0-3) identifying the format to be used for the definitions
///
/// Returns:
///  * A table with the definitions of the word according to the selected dictionaries
static int lookup(lua_State *L) {
  LuaSkin *skin = [LuaSkin sharedWithState:L];
  [skin checkArgs:LS_TSTRING, LS_TSTRING, LS_TNUMBER, LS_TBREAK];

  [skin logDebug:@"Starting lookup"];

  NSString *word = [skin toNSObjectAtIndex:1];
  NSArray *dictionaries;
  long dataVersion = (long)lua_tointeger(L, 3);;

  NSString *dictionaryName = [skin toNSObjectAtIndex:2];
  if ([dictionaryName isEqualToString:@"all"]) {
    dictionaries = (__bridge_transfer NSArray *)DCSCopyAvailableDictionaries();
  } else if ([dictionaryName isEqualToString:@"active"]) {
    dictionaries = (__bridge NSArray *)DCSGetActiveDictionaries();
  } else if ([dictionaryName isEqualToString:@"defaultDictionary"]) {
    dictionaries = @[(__bridge id)DCSGetDefaultDictionary()];
  } else if ([dictionaryName isEqualToString:@"defaultThesaurus"]) {
    dictionaries = @[(__bridge id)DCSGetDefaultThesaurus()];
  } else {
    DCSDictionaryRef dictionary = findDictionaryByName(dictionaryName);
    if (!dictionary) {
      return luaL_error(L, "Couldn't find dictionary '%s'", [dictionaryName UTF8String]);
    } else {
      dictionaries = @[(__bridge id)dictionary];
    }
  }

  lua_newtable(L);

  long i = 1;
  for (id dict in dictionaries) {
    DCSDictionaryRef dictionary = (__bridge DCSDictionaryRef) dict;

    CFRange termRange = DCSGetTermRangeInString(dictionary, (__bridge CFStringRef)word, 0);
    if (termRange.location == kCFNotFound) {
      continue;
    }

    NSString *term = [word substringWithRange:NSMakeRange(termRange.location, termRange.length)];

    NSArray *records = (__bridge_transfer NSArray *)DCSCopyRecordsForSearchString(dictionary, (__bridge CFStringRef)term, NULL, NULL);
    if (records) {
      NSString *dictionaryName = (__bridge NSString *)DCSDictionaryGetName(dictionary);
      for (id recordId in records) {
        CFTypeRef record = (__bridge CFTypeRef) recordId;

        lua_pushinteger(L, (lua_Integer)i++);
        lua_newtable(L);

        NSString *s;

        s = (__bridge_transfer NSString*) DCSRecordCopyData(record, dataVersion);
        [skin pushNSObject:s];
        lua_setfield(L, -2, "definition");
        s = (__bridge NSString*) DCSRecordGetHeadword(record);
        [skin pushNSObject:s];
        lua_setfield(L, -2, "headword");
        s = (__bridge NSString*) DCSRecordGetTitle(record);
        [skin pushNSObject:s];
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

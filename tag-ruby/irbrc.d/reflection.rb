class Object

  def methods_sorted(recur=false, objc=false)
    unsorted = if RUBY_ENGINE == "macruby"
      self.methods_unsorted(recur, objc)
    else
      recur ? self.methods_unsorted : self.methods_unsorted - Object.methods_unsorted
    end
    unsorted.map { |x| x.to_s }.sort
  end
  alias_method :methods_unsorted, :methods
  alias_method :methods, :methods_sorted

  if RUBY_ENGINE == "macruby"
    def objc_methods(recur=false)
      self.methods(recur, true) - self.methods(recur)
    end
  end

end

class Module

  def constants_sorted(*args)
    self.constants_unsorted.map { |x| x.to_s }.sort
  end
  alias_method :constants_unsorted, :constants
  alias_method :constants, :constants_sorted

end

tip 'use Object#methods_sorted and Module#constants_sorted'

if RUBY_ENGINE == "macruby"
  framework 'Foundation'
  framework 'ScriptingBridge'

  class SBElementsArray
    def [](value)
      self.objectWithName(value)
    end
  end

  def app(bundle_id)
    SBApplication.applicationWithBundleIdentifier(bundle_id)
  end

  tip 'use Object#objc_methods to get a list of available ObjC methods'
end

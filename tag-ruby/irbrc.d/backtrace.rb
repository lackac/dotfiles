module IRB
  class WorkSpace

    def evaluate_with_backtrace_saving(*args)
      evaluate_without_backtrace_saving(*args)
    rescue Exception => e
      puts "\e[31mException:\e[0m"
      e
    end

    alias_method :evaluate_without_backtrace_saving, :evaluate
    alias_method :evaluate, :evaluate_with_backtrace_saving

  end
end

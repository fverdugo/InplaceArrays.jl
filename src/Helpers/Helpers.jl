module Helpers

export @abstractmethod
export @notimplemented
export @notimplementedif
export @unreachable

macro abstractmethod()
  quote
    error("This function belongs to an interface definition and cannot be used.")
  end
end

macro notimplemented(message="This function is not yet implemented")
  quote
    error($(esc(message)))
  end
end

macro notimplementedif(condition,message="This function is not yet implemented")
  quote
    if $(esc(condition))
      @notimplemented $(esc(message))
    end
  end
end

macro unreachable(message="This line of code cannot be reached")
  quote
    error($(esc(message)))
  end
end

end # module Helpers

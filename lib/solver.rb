require "byebug"
require "pp"
require "json"

require "parslet"
require "parslet/convenience"

require_relative "parser"
require_relative "evaluator"

# in case of too deep
# class Parslet::Atoms::Context
#   def lookup(obj, pos)
#     p obj
#     @cache[pos][obj.object_id]
#   end
# end
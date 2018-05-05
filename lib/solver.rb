require "byebug"
require "pp"
require "json"

require "parslet"
require "parslet/convenience"

require_relative "infix_expression_parser"
require_relative "infix_interpreter"
require_relative "equations_solver"

# in case of too deep
# class Parslet::Atoms::Context
#   def lookup(obj, pos)
#     p obj
#     @cache[pos][obj.object_id]
#   end
# end
require 'pretty_validation/monkey/new_hash_syntax'

module PrettyValidation
  class Validation
    using NewHashSyntax

    attr_reader :method_name, :column_name, :options

    def self.sexy_validations(table_name)
      return [] if PrettyValidation.config.ignored_tables.include?(table_name)
      columns = Schema.columns(table_name)
      columns = columns.reject { |x| x.name.in? %w(id created_at updated_at) }

      columns.map do |column|
        next if PrettyValidation.config.ignored_columns.include?("#{table_name}.#{column.name}")
        options = {}
        options[:presence] = true unless column.null

        case column.type
        when :integer
          options[:numericality] = true
          options[:allow_nil] = true if column.null
        when :boolean
          options.delete(:presence)
          options[:inclusion] = [true, false]
          options[:allow_nil] = true if column.null
        when :string
          options[:length] = { maximum: column.limit } if column.limit
          options[:allow_nil] = true if column.null
        end

        Validation.new('validates', column.name.to_sym, options) if options.present?
      end.compact
    end

    def self.unique_validations(table_name)
      return [] if PrettyValidation.config.ignored_tables.include?(table_name)
      Schema.indexes(table_name).select(&:unique).reverse.map do |x|
        column_name = x.columns[0]
        scope = x.columns[1..-1].map(&:to_sym)
        options = if scope.size > 1
                    { scope: scope }
                  elsif scope.size == 1
                    { scope: scope[0] }
                  end

        columns = Schema.columns(table_name)
        string_exp = "%s.%s" % [table_name, x.columns.join('_')]
        next if PrettyValidation.config.ignored_uniqueness.include?(string_exp)
        if x.columns.any?{|colname| col = columns.detect{|c| c.name == colname}; col.null }
          options ||= {}
          options[:allow_nil] = true
        end
        Validation.new('validates_uniqueness_of', column_name.to_sym, options)
      end.compact
    end

    def initialize(method_name, column_name, options = nil)
      @method_name = method_name
      @column_name = column_name
      @options = options
    end

    def ==(other)
      method_name == other.method_name &&
        column_name == other.column_name &&
        options == other.options
    end

    def to_s
      if options.blank?
        "#{method_name} #{column_name.inspect}"
      else
        "#{method_name} #{column_name.inspect}, #{options.to_s}"
      end
    end
  end
end

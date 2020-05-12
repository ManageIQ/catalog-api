module Catalog
  class NameAdjust
    COPY_REGEX = '^Copy (\(\d\) )?of'.freeze

    def self.create_copy_name(original_name, names, max_length = nil)
      original_name.sub!(COPY_REGEX, '')
      names.select! { |name| name.match("#{COPY_REGEX} #{original_name}") }
      copied_name = copy_name(original_name, names)
      max_length ? copied_name.truncate(max_length) : copied_name
    end

    class << self
      private

      def get_index(names)
        ####
        # This chain of maps takes a match for "Copy (#) of #{name}" and returns the highest index.
        # The chain goes as follows
        # 1. raw names
        # 2. [ nil, "(2)", nil, nil, "(2)" ]    - map
        # 3. [ "(1)", "(2)" ]                   - compact
        # 4. [ 1, 2 ]                           - map
        # 5. 2                                  - max
        # 6. || 0, if there weren't any numbers, let's return 0 by default.
        names
          .map { |name| name.match(COPY_REGEX)&.captures&.first }
          .compact
          .map { |match| match.gsub(/[()]/, "").to_i }
          .max || 0
      end

      def copy_name(original_name, names)
        if names.any?
          num = get_index(names)
          "Copy (#{num + 1}) of " + original_name
        else
          "Copy of " + original_name
        end
      end
    end
  end
end

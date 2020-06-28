require "faker"
require "pry"

class Change < Struct.new(:binding, :git, :type)
  include Rfix::Log

  FIXTURES = {
    invalid: [[3], "invalid.rb"],
    valid: [[], "valid.rb"],
    unfixable: [[3], "unfixable.rb"],
    not_ruby: [[], "not_ruby.txt"]
  }.freeze

  CHANGES = {
    invalid: "puts \"double quoted\"",
    valid: "puts 'hello world'"
  }.freeze

  TYPES = {
    invalid: "{{red:invalid}}",
    valid: "{{blue:valid}}",
    unfixable: "{{cyan:unfixable}}",
    not_ruby: "{{magenta:not_ruby}}"
  }.freeze

  ACTIONS = {
    tracked: "{{yellow:tracked}}",
    untracked: "{{green:untracked}}",
    staged: "{{blue:staged}}",
    append: "{{red:append}}",
    insert: "{{cyan:insert}}",
    delete: "{{red:delete}}"
  }.freeze

  attr_reader :changed_lines, :lint_errors_at_lines

  def initialize(binding, git, type)
    @actions = []
    @changed_lines = []
    @lint_errors_at_lines = []
    super(binding, git, type)
  end

  def write!
    git.chdir { manipulate! }
  end

  def untracked
    tap { @actions.append([:untracked]) }
  end

  def tracked
    tap { @actions.append([:tracked]) }
  end

  def staged
    tap { @actions.append([:staged]) }
  end

  def append(type = :invalid)
    tap { @actions.append([:append, type]) }
  end

  def insert(type = :invalid, count = 1)
    tap do
      count.times do
        @actions.append([:insert, type])
      end
    end
  end

  def delete(type = :invalid)
    tap { @actions.append([:delete, type]) }
  end

  def inspect
    fmt "{{italic:#{to_path}}} (#{readable_actions})"
  end

  def to_path
    to_dest_path
  end

  def to_s
    return to_path if all_line_changes.empty?

    "#{to_path}:#{all_line_changes.join(':')}"
  end

  def all_line_changes
    changed_lines + lint_errors_at_lines
  end

  private

  def readable_actions
    actions = @actions.map do |name, *args|
      "#{to_color(name)}#{to_tail(args)}"
    end.join(" {{blue:⇢}} ")

    "#{type_prefix}#{actions}"
  end

  def type_prefix
    "{{italic:#{TYPES.fetch(type)}}} {{>}} "
  end

  def to_color(name)
    "{{italic:#{ACTIONS.fetch(name)}}}"
  end

  def to_tail(args)
    return "" if args.empty?

    "{{italic:(#{args.join('')})}}"
  end

  def manipulate!
    @lint_errors_at_lines.append(*FIXTURES.fetch(type).first)
    binding.copy(to_fixture, to_dest_path)
    @actions.each do |action, *args|
      send(:"perform_#{action}", *args)
    end
  end

  def perform_staged
    git.add(to_dest_path)
  end

  def perform_tracked
    git.add(to_dest_path)
    git.commit("Add #{to_dest_path} file")
  end

  def random_line_number
    return 1 if file_lines.empty?

    Faker::Number.between(from: 1, to: file_lines.count)
  end

  def perform_insert(type)
    lines = file_lines.dup
    count = lines.count
    row_number = random_line_number
    lines = lines.insert(row_number - 1, CHANGES.fetch(type))

    File.write(to_dest_path, lines.join("\n"))

    @changed_lines.each_with_index do |value, index|
      if value >= row_number
        @changed_lines[index] += 1
      end
    end

    @lint_errors_at_lines.each_with_index do |value, index|
      if value >= row_number
        @lint_errors_at_lines[index] += 1
      end
    end

    unless type == :valid
      @changed_lines.append(row_number)
    end
  end

  def random_delete_number(type, rows)
    if rows.empty?
      say_abort "Could not find row to delete"
    end

    pot_row = rows.pop

    if type == :valid
      unless all_line_changes.include?(pot_row)
        return pot_row
      end

      return random_delete_number(type, rows)
    end

    if all_line_changes.include?(pot_row)
      return pot_row
    end

    return random_delete_number(type, rows)
  end

  def perform_delete(type)
    lines = file_lines
    max_row_number = lines.count
    row_to_delete = random_delete_number(type, (1..max_row_number).to_a.shuffle)
    lines.delete_at(row_to_delete - 1)
    File.write(to_dest_path, lines.join("\n"))

    @changed_lines.each_with_index do |value, index|
      if value == row_to_delete
        @changed_lines.delete(row_to_delete)
      elsif value >= row_to_delete
        @changed_lines[index] -= 1
      end
    end

    @lint_errors_at_lines.each_with_index do |value, index|
      if value == row_to_delete
        @lint_errors_at_lines.delete(row_to_delete)
      elsif value >= row_to_delete
        @lint_errors_at_lines[index] -= 1
      end
    end
  end

  def display_file!
    File.read(to_dest_path).lines.each_with_index do |line, index|
      say_debug "#{index + 1} #{line}"
    end
  end

  def perform_untracked
    # NOP
  end

  def perform_append(type)
    File.open(to_dest_path, "a") do |f|
      f.write CHANGES.fetch(type)
    end
    @changed_lines.append(file_lines.count)
  end

  def file_lines
    File.read(to_dest_path).lines(chomp: true)
  end

  def to_fixture
    "%/#{to_fixture_path}"
  end

  def to_fixture_path
    FIXTURES.fetch(type).last
  end

  def tags
    @actions.map(&:first).flatten
  end

  def random(number:)
    Faker::Number.between(from: 0, to: number)
  end

  def to_dest_path
    @to_dest_path ||= begin
      count = random(number: 3)
      dir = Faker::File.dir(segment_count: count, root: nil)
      dir = dir.delete_prefix("/")
      ext = File.extname(to_fixture_path)

      dir = "." if count == 0

      Faker::File.file_name(
        dir: dir,
        ext: ext.delete_prefix(".")
      ).delete_prefix("./")
    end
  end
end

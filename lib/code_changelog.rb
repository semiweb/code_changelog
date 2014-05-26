require 'code_changelog/version'

module CodeChangelog
  class CodeChangelogEntry < ActiveRecord::Base
  end

  class CodeChangelog
    def initialize(start_date=nil, end_date=nil, show_committed=false)
      @start_date     = start_date
      @end_date       = end_date
      @show_committed = show_committed
      @changelogs     = self.all_changelogs()

      if not @show_committed
        self.exclude_already_done(@changelogs)
      end
      self.keep_from_date_to_date()
      @changelogs.each do |f|
        f[:content] = YAML.load_file("#{Rails.root}/doc/changelog/#{f[:filename]}")
      end
    end

    def generate_content()
      content = ''
      @changelogs.each do |cl|
        content << cl.content['description']
        content << "\n"
      end
      content
    end

    def generate_list()
      @changelogs
    end

    def self.from_date_to_date(start_date, end_date)
      CodeChangelog.new(start_date, end_date)
    end

    def self.from_date_to_date_from_uncommitted(start_date, end_date)
      CodeChangelog.new(start_date, end_date, true)
    end

    def commit()
      changelogs = @changelogs.clone
      self.exclude_already_done(changelogs)
      changelogs.each do |cl|
        CodeChangelogEntry.new({'version' => cl[:timestamp]}).save
      end
    end

    #private

    def keep_from_date_to_date()
      return if @start_date.blank? or @end_date.blank?

      @changelogs.select! do |cl|
        @start_date <= cl[:timestamp] and cl[:timestamp] <= @end_date
      end
    end

    def exclude_already_done(changelogs)
      already_done = Set.new(CodeChangelogEntry.pluck(:version))
      changelogs.reject! do |cl|
        already_done.include? cl[:timestamp]
      end
    end


    def all_changelogs()
      changelogs = Dir.entries("#{Rails.root}/doc/changelog")
      changelogs.select! do |f|
        /^\d{14}_.*\.yml$/.match(f)
      end
      changelogs.map do |f|
        {filename: f,
         timestamp: f[/^\d{14}/, 0]}
      end
    end
  end
end

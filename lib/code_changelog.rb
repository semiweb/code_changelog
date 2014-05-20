require 'code_changelog/version'
#require 'generators/migration_generator'
#require 'generators/code_changelog_generator'

module CodeChangelog
  class CodeChangelog < ActiveRecord::Base
  end

  class CodeChangelogManager
    def send_mail()
      changelogs = self._all_changelogs()
      self._exclude_already_done(changelogs)
      changelogs.each do |cl|
        changelog = YAML.load_file("#{Rails.root}/doc/changelog/#{cl[:filename]}")
        puts changelog
        puts changelog['description']
        CodeChangelog.new({'version' => cl[:timestamp]}).save
      end
    end

    def _exclude_already_done(changelogs)
      already_done = CodeChangelog.all.map{|cc| cc[:version]}
      changelogs.reject! do |cl|
        already_done.include? cl[:timestamp]
      end
    end

    def _all_changelogs()
      all_files = Dir.entries("#{Rails.root}/doc/changelog")
      all_files.select! do |f|
        /^\d{14}_.*\.yml$/.match(f)
      end
      all_files.map do |f|
        {filename: f,
         timestamp: f[/^\d{14}/, 0]}
      end
    end
  end
end

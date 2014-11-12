# encoding: utf-8

module CodeChangelog
  require "code_changelog/railtie" if defined?(Rails)

  class ArmaCodeChangelogEntry < ActiveRecord::Base
    def timestamp()
      self.filename[/^\d{14}/, 0]
    end

    def yaml_content()
      @content ||= YAML.load_file(File.join(self.directory, self.filename))
    end

    def description()
      self.yaml_content()['description']
    end

    def affect()
      self.yaml_content()['affect']
    end
  end

  class ArmaCodeChangelog
    def initialize(directory, changelogs_ids = nil)
      @directory  = directory
      @changelogs = self.all_changelogs(changelogs_ids)
    end

    def self.update_directory(directory, changelogs_hashes)
      changelogs_hashes.each do |changelog_hash|
        file_path = File.join(directory, changelog_hash['filename'])
        if changelog_hash['status'] == 'new' || changelog_hash['status'] == 'modified'
          FileUtils.mkdir_p(directory)
          File.open(file_path, 'w') { |file| file.write(changelog_hash['content']) }
          if changelog_hash['status'] == 'new'
            if not ArmaCodeChangelogEntry.exists?(filename: changelog_hash['filename'], directory: directory)
              ArmaCodeChangelogEntry.create!(filename: changelog_hash['filename'], directory: directory)
            end
          end
        elsif changelog_hash['status'] == 'deleted'
          ArmaCodeChangelogEntry.where(directory: directory, filename: changelog_hash['filename']).destroy_all()
          FileUtils.rm_f(file_path)
        end
      end
    end

    def generate_content()
      content = "Voici les dernière modifications depuis la dernière mise à jour :\n\n"
      @changelogs.each do |cl|
        content << "#{cl.description}\n\n"
      end
      content
    end

    def generate_list()
      @changelogs
    end

    def commit()
      @changelogs.each do |cl|
        cl.update_attributes!(committed_at: DateTime.now)
      end
    end

    def nb_uncommitted()
      @changelogs.where(committed_at: nil).size
    end

    #private

    def all_changelogs(changelogs_ids)
      return ArmaCodeChangelogEntry.where(directory: @directory).order(filename: :desc) if changelogs_ids.nil?
      ArmaCodeChangelogEntry.where(id: changelogs_ids)
    end
  end
end

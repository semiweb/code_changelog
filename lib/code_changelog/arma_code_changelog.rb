# encoding: utf-8

include ActionView::Helpers::TextHelper

module CodeChangelog
  require "code_changelog/railtie" if defined?(Rails)

  class ArmaCodeChangelogEntry < ActiveRecord::Base
    def timestamp()
      self.filename[/^\d{14}/, 0]
    end

    def content()
      YAML.load_file(File.join(Rails.root, self.directory, self.filename))
    end
  end

  class ArmaCodeChangelog
    def initialize(directory, changelogs_ids = nil)
      @directory  = directory
      @changelogs = self.all_changelogs(changelogs_ids)
    end

    def self.update_directory(directory, changelogs)
      changelogs.each do |changelog|
        file_path = File.join(directory, changelog['filename'])
        if changelog['status'] == 'new' || changelog['status'] == 'modified'
          FileUtils.mkdir_p(directory)
          File.open(file_path, 'w') { |file| file.write(changelog['content']) }
          if changelog['status'] == 'new'
            ArmaCodeChangelogEntry.create!(filename: changelog['filename'], directory: directory)
          end
        elsif changelog['status'] == 'deleted'
          ArmaCodeChangelogEntry.where(directory: directory, filename: changelog['filename']).delete_all()
          FileUtils.remove(file_path)
        end
      end
    end

    def generate_content()
      content = 'Voici les dernière modifications depuis la dernière mise à jour :<br><br>'
      @changelogs.each do |cl|
        content << simple_format(cl.content()['description'])
      end
      content
    end

    def generate_list()
      @changelogs
    end

    def commit()
      @changelogs.each do |cl|
        cl.update(committed_at: DateTime.now)
      end
    end

    #private

    def all_changelogs(changelogs_ids)
      return ArmaCodeChangelogEntry.where(directory: @directory).order(filename: :desc) if changelogs_ids.nil?
      ArmaCodeChangelogEntry.where(id: changelogs_ids)
    end
  end
end


module CodeChangelog
  require "code_changelog/railtie" if defined?(Rails)

  class ArmaCodeChangelogEntry < ActiveRecord::Base
    belongs_to :installation

    def timestamp()
      self.filename[/^\d{14}/, 0]
    end
  end

  class ArmaCodeChangelog
    def initialize(directory, changelogs_ids = nil)
      @directory  = directory
      @changelogs = self.all_changelogs(changelogs_ids)
      @changelogs.map! do |changelog|
        {
          db_obj: changelog,
          content: YAML.load_file(File.join(Rails.root, @directory, changelog[:filename]))
        }
      end
    end

    def self.update_directory(installation, changelogs)
      directory = File.join('doc', installation.application.name, installation.name, installation.env, installation.location == 'undefined' ? '' : installation.location)
      changelogs.each do |changelog|
        file_path = File.join(directory, changelog['filename'])
        if changelog['status'] == 'new' || changelog['status'] == 'modified'
          FileUtils.mkdir_p(directory)
          File.open(file_path, 'w') { |file| file.write(changelog['content']) }
          if changelog['status'] == 'new'
            ArmaCodeChangelogEntry.create!(filename: changelog['filename'], installation: installation)
          end
        elsif changelog['status'] == 'deleted'
          ArmaCodeChangelogEntry.where(installation: installation, filename: changelog['filename']).delete_all()
          FileUtils.remove(file_path)
        end
      end
    end

    def generate_content()
      content = ''
      @changelogs.each do |cl|
        content << cl[:content]['description']
        content << "<br><br>"
      end
      content
    end

    def generate_list()
      @changelogs
    end

    def commit()
      @changelogs.each do |cl|
        cl[:db_obj].update(committed: true)
      end
    end

    #private

    def all_changelogs(changelogs_ids)
      return ArmaCodeChangelogEntry.all() if changelogs_ids.nil?
      ArmaCodeChangelogEntry.where(id: changelogs_ids)
    end
  end
end

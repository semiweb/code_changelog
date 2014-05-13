module CodeChangelog
  class CodeChangelogGenerator < Rails::Generators::NamedBase
    desc "This generator creates a new changelog file"
    def create_changelog_file
      create_file "doc/changelog/#{Time.now.utc.strftime("%Y%m%d%H%M%S")}_#{file_name}.yml", <<DATA
affects: all
description: Write your new stuff here
DATA

    end
  end
end

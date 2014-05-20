module CodeChangelog
  class MigrationGenerator < Rails::Generators::Base
    desc "This generator creates the migration file"
    def create_migration_file
      create_file "db/migrate/#{Time.now.utc.strftime("%Y%m%d%H%M%S")}_code_changelog_migration.rb", <<DATA
class CodeChangelogMigration < ActiveRecord::Migration
  def change
    create_table :code_changelogs do |t|
      t.string :version
    end
  end
end
DATA

    end
  end
end

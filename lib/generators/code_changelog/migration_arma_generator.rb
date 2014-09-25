module CodeChangelog
  class MigrationArmaGenerator < Rails::Generators::Base
    desc "This generator creates the arma migration file"
    def create_migration_file
      create_file "db/migrate/#{Time.now.utc.strftime("%Y%m%d%H%M%S")}_code_changelog_entry_migration.rb", <<DATA
class CodeChangelogEntryMigration < ActiveRecord::Migration
  def change
    create_table :arma_code_changelog_entries do |t|
      t.string :filename
      t.string :directory, index: true
      t.boolean :committed, default: false

      t.timestamps
    end
  end
end
DATA

    end
  end
end

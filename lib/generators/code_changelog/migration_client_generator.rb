module CodeChangelog
  class MigrationClientGenerator < Rails::Generators::Base
    desc "This generator creates the client migration file"
    def create_migration_file
      create_file "db/migrate/#{Time.now.utc.strftime("%Y%m%d%H%M%S")}_client_code_changelog_entry_migration.rb", <<DATA
class ClientCodeChangelogEntryMigration < ActiveRecord::Migration
  def change
    create_table :client_code_changelog_entries do |t|
      t.string :filename
      t.string :file_hash
    end
  end
end
DATA

    end
  end
end

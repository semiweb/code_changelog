module CodeChangelog
  require "code_changelog/railtie" if defined?(Rails)

  class ClientCodeChangelogEntry < ActiveRecord::Base
  end

  class ClientCodeChangelog
    def initialize()
      @directory = 'doc/changelog/'
    end

    def changelogs_diff()
      changelogs_files = Dir["#{@directory}*"].map{|path| {filename: File.basename(path), file_hash: Digest::MD5.file(path).hexdigest}}

      changelogs_sent = ClientCodeChangelogEntry.all

      changelogs_files = Hash[changelogs_files.map {|o| [o[:filename], o]}]

      changelogs = changelogs_sent.map do |changelog_sent|
        changelog_hash = {filename: changelog_sent.filename, file_hash: changelog_sent.file_hash}

        if changelogs_files[changelog_sent.filename].present?
          if changelogs_files[changelog_sent.filename][:file_hash] == changelog_sent[:file_hash]
            changelog_hash[:status] = :unmodified
          else
            changelog_hash[:status] = :modified
          end
          changelog_hash[:file_hash] = changelogs_files[changelog_sent.filename][:file_hash]
          changelogs_files.delete(changelog_sent.filename)
        else
          changelog_hash[:status] = :deleted
        end

        changelog_hash
      end

      changelogs_files.each_value do |changelog_file|
        changelogs << {filename: changelog_file[:filename], status: :new, file_hash: changelog_file[:file_hash]}
      end

      changelogs.reject do |changelog|
        changelog[:status] == :unmodified
      end
    end

    def get_and_commit()
      changelogs = self.changelogs_diff
      changelogs.each do |changelog|
        if changelog[:status] == :new || changelog[:status] == :modified
          changelog[:content] = File.read(File.join(@directory, changelog[:filename]))
        end

        if changelog[:status] == :new
          ClientCodeChangelogEntry.create!(filename: changelog[:filename], file_hash: changelog[:file_hash])
        elsif changelog[:status] == :modified
          ClientCodeChangelogEntry.where(filename: changelog[:filename]).first.update_attributes!(file_hash: changelog[:file_hash])
        elsif changelog[:status] == :deleted
          ClientCodeChangelogEntry.where(filename: changelog[:filename]).first.delete
        end
      end
      changelogs
    end

  end
end

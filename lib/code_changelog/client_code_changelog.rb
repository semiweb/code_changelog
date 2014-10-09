module CodeChangelog
  require "code_changelog/railtie" if defined?(Rails)

  class ClientCodeChangelogEntry < ActiveRecord::Base
  end

  class ClientCodeChangelogFile
    attr_accessor :file_hash, :filename
    def initialize file_path
      @file_path = file_path
      @filename  = File.basename(file_path)
      begin
        @file_hash = Digest::MD5.file(file_path).hexdigest
      rescue
      end
    end

    def content()
      @content ||= File.read(@file_path)
    end

    def to_hash(status)
      hash = {}
      hash[:status]    = status
      hash[:filename]  = @filename
      hash[:file_hash] = @file_hash
      if status == :new || status == :modified
        hash[:content] = self.content
      end
      hash
    end
  end

  class ClientCodeChangelogCollection
    attr_accessor :new_logs, :modified_logs, :unmodified_logs, :deleted_logs
    def initialize
      @new_logs        = []
      @modified_logs   = []
      @unmodified_logs = []
      @deleted_logs    = []
      @changelogs_sent = Hash[ClientCodeChangelogEntry.all.map {|o| [o.filename, o]}]
    end

    def add(changelogs_files)
      changelogs_files.each do |changelog_file|
        changelog_sent = @changelogs_sent[changelog_file.filename]
        if changelog_sent.present?
          if changelog_sent.file_hash == changelog_file.file_hash
            @unmodified_logs.push changelog_file
          else
            @modified_logs.push changelog_file
          end
          @changelogs_sent.delete(changelog_sent.filename)
        else
          @new_logs.push changelog_file
        end
      end

      @changelogs_sent.each_value do |changelog_sent|
        @deleted_logs.push(ClientCodeChangelogFile.new(changelog_sent.filename))
      end
    end

    def commit()
      @new_logs.each do |changelog|
        ClientCodeChangelogEntry.create!(filename: changelog.filename, file_hash: changelog.file_hash)
      end
      @modified_logs.each do |changelog|
        ClientCodeChangelogEntry.find_by_filename!(changelog.filename).update_attributes!(file_hash: changelog.file_hash)
      end
      @deleted_logs.each do |changelog|
        ClientCodeChangelogEntry.find_by_filename!(changelog.filename).destroy
      end
    end

    def format()
      changelogs = @new_logs.map do |changelog|
        changelog.to_hash(:new)
      end
      changelogs += @modified_logs.map do |changelog|
        changelog.to_hash(:modified)
      end
      changelogs += @deleted_logs.map do |changelog|
        changelog.to_hash(:deleted)
      end
      changelogs
    end
  end

  class ClientCodeChangelog
    def initialize()
      @directory = 'doc/changelog/'

      changelogs_files = Dir["#{@directory}*"].map{|file_path| ClientCodeChangelogFile.new(file_path)}

      @changelog_collection = ClientCodeChangelogCollection.new
      @changelog_collection.add(changelogs_files)
    end

    def changelogs_diff()
      @changelog_collection.format
    end

    def commit()
      @changelog_collection.commit
    end
  end
end

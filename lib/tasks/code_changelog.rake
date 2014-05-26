# encoding: utf-8
namespace :code_changelog do

  desc 'Generate code changelogs'
  task :generate, [:start_date, :end_date] => :environment do |t, args|
    start_date = (args[:start_date] or '0').to_s
    end_date   = (args[:end_date]   or '99999999999999').to_s
    changelog_manager = CodeChangelog::CodeChangelog.from_date_to_date(start_date, end_date)
    puts changelog_manager.generate_content
  end

  desc 'Commit code changelogs'
  task :commit, [:start_date, :end_date] => :environment do |t, args|
    start_date = (args[:start_date] or '0').to_s
    end_date   = (args[:end_date]   or '99999999999999').to_s
    changelog_manager = CodeChangelog::CodeChangelog.from_date_to_date(start_date, end_date)
    puts changelog_manager.generate_content
    changelog_manager.commit
    puts 'Changelogs committed !'
  end

end

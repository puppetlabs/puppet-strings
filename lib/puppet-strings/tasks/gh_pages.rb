# frozen_string_literal: true

require 'English'
require 'puppet-strings/tasks'

namespace :strings do
  namespace :gh_pages do
    task :checkout do
      if Dir.exist?('doc')
        raise "The 'doc' directory (#{File.expand_path('doc')}) is not a Git repository! Remove it and run the Rake task again." unless Dir.exist?('doc/.git')

        Dir.chdir('doc') do
          system 'git checkout gh-pages'
          exit 1 unless $?.success?
          system 'git pull --rebase origin gh-pages'
          exit 1 unless $?.success?
        end
      else
        git_uri = `git config --get remote.origin.url`.strip
        raise "Could not determine the remote URL for origin: ensure the current directory is a Git repro with a remote named 'origin'." unless $CHILD_STATUS.success?

        Dir.mkdir('doc')
        Dir.chdir('doc') do
          system 'git init'
          exit 1 unless $?.success?
          system "git remote add origin #{git_uri}"
          exit 1 unless $?.success?
          system 'git pull origin gh-pages'
          exit 1 unless $?.success?
          system 'git checkout -b gh-pages'
          exit 1 unless $?.success?
        end
      end
    end

    task :configure do
      unless File.exist?(File.join('doc', '_config.yml'))
        Dir.chdir('doc') do
          File.write('_config.yml', 'include: _index.html')
        end
      end
    end

    # Task to push the gh-pages branch. Argument :msg_prefix is the beginning
    # of the message and the actual commit will have "at Revision <git_sha>"
    # appended.
    task :push, [:msg_prefix] do |_t, args|
      msg_prefix = args[:msg_prefix] || '[strings] Generated Documentation Update'

      output = `git describe --long 2>/dev/null`
      # If a project has never been tagged, fall back to latest SHA
      git_sha = output.empty? ? `git log --pretty=format:'%H' -n 1` : output

      Dir.chdir('doc') do
        system 'git add .'
        exit 1 unless $?.success?
        system "git commit -m '#{msg_prefix} at Revision #{git_sha}'"
        # Do not check status of commit, as it will error if there are no changes.
        system 'git push origin gh-pages -f'
        exit 1 unless $?.success?
      end
    end

    desc 'Update docs on the gh-pages branch and push to GitHub.'
    task update: %i[
      checkout
      strings:generate
      configure
      push
    ]
  end
end

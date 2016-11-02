require 'puppet-strings/tasks'

namespace :strings do
  namespace :gh_pages do
    task :checkout do
      if Dir.exist?('doc')
        fail "The 'doc' directory (#{File.expand_path('doc')}) is not a Git repository! Remove it and run the Rake task again." unless Dir.exist?('doc/.git')
        Dir.chdir('doc') do
          system 'git checkout gh-pages'
          system 'git pull --rebase origin gh-pages'
        end
      else
        git_uri = `git config --get remote.origin.url`.strip
        fail "Could not determine the remote URL for origin: ensure the current directory is a Git repro with a remote named 'origin'." unless $?.success?

        Dir.mkdir('doc')
        Dir.chdir('doc') do
          system 'git init'
          system "git remote add origin #{git_uri}"
          system 'git pull origin gh-pages'
          system 'git checkout -b gh-pages'
        end
      end
    end

    task :configure do
      unless File.exist?(File.join('doc', '_config.yml'))
        Dir.chdir('doc') do
          File.open('_config.yml', 'w+') {|f| f.write("include: _index.html") }
        end
      end
    end

    task :push do
      output = `git describe --long 2>/dev/null`
      # If a project has never been tagged, fall back to latest SHA
      output.empty? ? git_sha = `git log --pretty=format:'%H' -n 1` : git_sha = output

      Dir.chdir('doc') do
        system 'git add .'
        system "git commit -m '[strings] Generated Documentation Update at Revision #{git_sha}'"
        system 'git push origin gh-pages -f'
      end
    end

    desc 'Update docs on the gh-pages branch and push to GitHub.'
    task :update => [
      :checkout,
      :'strings:generate',
      :configure,
      :push,
    ]
  end
end

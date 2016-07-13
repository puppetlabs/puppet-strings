require 'rake'
require 'rake/tasklib'
require 'puppet/face'
require 'puppet_x/puppetlabs/strings/util'

namespace :strings do
  desc 'Generate Puppet documentation with YARD.'
  task :generate do
    PuppetX::PuppetLabs::Strings::Util.generate([
      {emit_json: 'strings.json'}
    ])
  end

  desc 'Serve YARD documentation for modules.'
  task :serve do
    PuppetX::PuppetLabs::Strings::Util.serve
  end

  namespace :gh_pages do
    git_uri = `git config --get remote.origin.url`.strip

    desc "Checkout the gh-pages branch for doc generation."
    task :checkout do
      if Dir.exist?('doc')
        fail "The 'doc' directory (#{File.expand_path('doc')}) is not a Git repository! Remove it and run the Rake task again." unless Dir.exist?('doc/.git')
        Dir.chdir('doc') do
          system 'git checkout gh-pages'
          system 'git reset --hard origin/gh-pages'
          system 'git pull origin gh-pages'
        end
      else
        Dir.mkdir('doc')
        Dir.chdir('doc') do
          system 'git init'
          system "git remote add origin #{git_uri}"
          system 'git pull'
          system 'git checkout -b gh-pages'
        end
      end
    end

    desc "Push new docs to GitHub."
    task :push do
      Dir.chdir('doc') do
        system 'git add .'
        system "git commit -m '[strings] Generated Documentation Update'"
        system 'git push origin gh-pages -f'
      end
    end

    desc "Run checkout, generate, and push tasks."
    task :update => [
      :checkout,
      :'strings:generate',
      :push,
    ]
  end
end

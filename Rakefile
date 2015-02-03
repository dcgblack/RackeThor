require 'rake/testtask'

namespace :test do
  
  Rake::TestTask.new(:functional) do |t|
    t.test_files = FileList['tests/functional/**/test*.rb']
    t.verbose = true
  end

  Rake::TestTask.new(:units) do |t|
    t.test_files = FileList['tests/units/test*.rb', 
      'tests/units/racket/test*.rb', 'tests/units/racket/**/test*.rb']
    t.verbose = true
  end
  
  task :all do 
    Rake::Task["test:functional"].execute
    Rake::Task["test:units"].execute
  end
end

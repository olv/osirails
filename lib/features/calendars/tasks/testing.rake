namespace :osirails do
  namespace :calendars do
    desc "Run all unit, functional and integration tests for calendars feature"
    task :test do
      %w(osirails:calendars:test:units osirails:calendars:test:functionals osirails:calendars:test:integration).collect do |task|
        Rake::Task[task].invoke
      end
    end
    
    namespace :test do
      Rake::TestTask.new(:units) do |t|
        t.libs << "test"
        t.pattern = "#{File.dirname(__FILE__)}/../test/unit/*_test.rb"
        t.verbose = true
      end
      Rake::Task['osirails:calendars:test:units'].comment = "Run the calendars unit tests"
      
      Rake::TestTask.new(:functionals) do |t|
        t.libs << "test"
        t.pattern = "#{File.dirname(__FILE__)}/../test/functional/*_test.rb"
        t.verbose = true
      end
      Rake::Task['osirails:calendars:test:functionals'].comment = "Run the calendars functional tests"
      
      Rake::TestTask.new(:integration) do |t|
        t.libs << "test"
        t.pattern = "#{File.dirname(__FILE__)}/../test/integration/*_test.rb"
        t.verbose = true
      end
      Rake::Task['osirails:calendars:test:integration'].comment = "Run the calendars integration tests"
    end
  end
end

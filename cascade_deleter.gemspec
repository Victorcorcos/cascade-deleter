Gem::Specification.new do |s|
  s.name                  = 'cascade-deleter'
  s.version               = '0.1.0'
  s.platform              = Gem::Platform::RUBY
  s.authors               = ['Victor Cordeiro Costa']
  s.email                 = ['victorcorcos@gmail.com']
  s.description           = %q{cascade-deleter is a ruby gem designed to delete items
                               with all of their descendant items in their hierarchy.}
  s.homepage              = 'https://github.com/Victorcorcos/cascade-deleter'
  s.summary               = %q{cascade-deleter is a ruby gem designed to delete items
                               with all of their descendant items in their hierarchy.}
  s.files                 = ['lib/cascade_deleter.rb', 'lib/deactivator.rb']
  s.require_paths         = ['lib']
  s.required_ruby_version = '>= 2.0'
  s.license               = 'MIT'

  s.add_development_dependency 'hierarchy-tree', '~> 0.3.5'
  s.add_development_dependency 'minitest', '~> 5.10'
  s.add_development_dependency 'rake', '~> 12.1'
  # s.add_dependency 'activerecord', '>=4.2'
end

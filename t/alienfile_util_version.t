use Test2::V0 -no_srand => 1;
use alienfile::util qw( version );

subtest 'basic' => sub {

  my $version = version('1.2.3');
  isa_ok $version, 'alienfile::util::version';

  is $version->as_string, '1.2.3', 'stringify';
  is "$version", '1.2.3', 'interpolate stringify';

};

subtest 'compare' => sub {

  is(version('1.2.3') >  version('1.2.2'),   T(), 'gt');
  is(version('1.2.3') <  version('1.2.4'),   T(), 'lt');
  is(version('1.2.3') == version('1.2.3'),   T(), 'eq (1)');
  is(version('1.2.3') == version('1.2.3.0'), T(), 'eq (2)');

  is(version('1.2.3') >= version('1.2.2'),   T(), 'ge (1)');
  is(version('1.2.3') >= version('1.2.3'),   T(), 'ge (2)');
  
  is(version('1.2.3') <= version('1.2.4'),   T(), 'le (1)');
  is(version('1.2.3') <= version('1.2.3'),   T(), 'le (2)');

};

done_testing;

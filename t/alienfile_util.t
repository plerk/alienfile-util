use Test2::V0 -no_srand => 1;
use Test::Alien::Build;
use alienfile::util ();
use Path::Tiny ();

subtest 'path' => sub {

  my $build = alienfile_ok q{
    use alienfile;
    use alienfile::util;

    probe sub { 'share' };
    
    share {
    
      download sub {
        path('file1')->spew('thefile1');
      };
      extract sub {
        path('file2')->spew('thefile2');
      };
      build sub {
        my($build) = @_;
        my $stage = $build->install_prop->{stage};
        path($stage)->child('file3')->spew('thefile3');
      };
    
    };    
  };

  alien_build_ok;
  
  my $file3 = Path::Tiny->new($build->install_prop->{stage})->child('file3');
  
  is(
    $file3,
    object {
      call 'slurp' => 'thefile3';
    },
    'file3 installed as file3',
  );

};

subtest 'capture' => sub {

  my $build = alienfile_ok q{
    use alienfile;
    use alienfile::util;
    
    probe sub { 'share' };
    
    share {
    
      download sub {
        path('file1')->spew('thefile1');
      };
      extract sub {
        path('file2')->spew('thefile2');
      };
      build sub {
        my($build) = @_;
        my $pl = path('foo.pl');
        $pl->spew(q{
          use strict;
          no warnings;
          print STDOUT "==this is stdout==\n";
          print STDERR "--this is stderr--\n";
        });
        my($out, $err, $ret) = capture {
          system $^X, "$pl";
          "~~this is ret~~\n";
        };
        my $stage = path($build->install_prop->{stage});
        $stage->child('file3')->spew("$out$err$ret");
      };
    };
  };

  alien_build_ok;

  my $file3 = Path::Tiny->new($build->install_prop->{stage})->child('file3');

  is(
    [$file3->lines],
    ["==this is stdout==\n", "--this is stderr--\n", "~~this is ret~~\n"],
    'output matches',
  );

};

done_testing

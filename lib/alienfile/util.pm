package alienfile::util;

use strict                            ;
use warnings                          ;
use 5.008001                          ;
use Path::Tiny    0.077 qw( path )    ;
use Capture::Tiny 0.17  qw( capture ) ;
use File::Which   1.20  qw( which )   ;
use base                qw( Exporter );

# ABSTRACT: Handy tools for manual alienfiles
# VERSION

=head1 SYNOPSIS

 use alienfile;
 use alienfile::util;

=head1 DESCRIPTION

This module provides some utilities that are useful for writing manual 
L<alienfile>s (the somewhat frequent problem when plugins do not handle
100% of what you need).  These utilities have historically proven themselves
useful in writing L<Alienfile>s in the past.  The reason this has not been
included with L<alienfile> or L<Alien::Build> core is that they expose some
external interfaces (such as L<Path::Tiny> or L<Capture::Tiny>), which may
not always be a dependency of the core L<Alien::Build> module.

=head1 FUNCTIONS

All of these are exported by default.

=head2 capture

 my($out, $err, $ret) = capture {
   ...
 };

This is simply C<capture> from L<Capture::Tiny>.

=head2 path

 my $path = path($pathname);

This is simply C<path> from L<Path::Tiny>.

=head2 version

 my $version = version($versionnumber);

This returns an object which you can perform numeric comparisons on.
For example these are true:

 version('1.2.3') >  version('1.2.2');
 version('1.2.3') == version('1.2.3.0');

=head2 which

 my $file = which($program);
 my @files = which($program);

This is simply C<which> from L<File::Which>.  The implementation may
in the future change, but the interface should remain the same.

=head1 SEE ALSO

=cut

our @EXPORT = qw( path capture which version );
our @EXPORT_OK = @EXPORT;

sub version
{
  alienfile::util::version->new($_[0]||die "invalid version: $_[0]");
}

package alienfile::util::version;

use Sort::Versions ();

use overload
  '""'  => sub { shift->as_string },
  '<=>' => sub { shift->_cmp(@_) },
  ;

sub new
{
  my($class, $version) = @_;
  bless \$version, $class;
}

sub as_string
{
  my($self) = @_;
  "@{[ $$self ]}";
}

sub _cmp
{
  my @a = (${$_[0]} =~ /([-.]|[0-9]+|[^-.0-9]+)/g);
  my @b = (${$_[1]} =~ /([-.]|[0-9]+|[^-.0-9]+)/g);

  while(@a and @b)
  {
    my($a, $b) = (shift @a, shift @b);
    if($a eq '-' and $b eq '-')
    {  next }
    elsif($a eq '-')
    { return -1 }
    elsif($b eq '-')
    { return 1 }
    elsif($a eq '.' and $b eq '.')
    {  next }
    elsif($a eq '.')
    { return -1 }
    elsif($b eq '.')
    { return 1 }
    elsif($a =~ /^[0-9]+$/ and $b =~ /^[0-9]+$/)
    {
      return $a <=> $b if $a <=> $b;
    }
    else
    {
      return $a cmp $b if $a cmp $b;
    }
  }
  @a <=> @b;  
}

1;

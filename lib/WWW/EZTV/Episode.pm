package WWW::EZTV::Episode;
use Moose;
with 'WWW::EZTV::UA';

# ABSTRACT: EZTV single episode

has show     => is => 'ro', isa => 'WWW::EZTV::Show', required => 1;
has title    => is => 'ro', isa => 'Str', required => 1;
has url      => is => 'ro', isa => 'Mojo::URL', required => 1;
has links    => is => 'rw';

has _parsed  => is => 'ro', lazy => 1, builder => '_parse';

has name     => is => 'ro', lazy => 1, 
    default  => sub { shift->_parsed->{name} };

has season     => is => 'ro', lazy => 1, 
    default  => sub { shift->_parsed->{season} };

has number     => is => 'ro', lazy => 1, 
    default  => sub { shift->_parsed->{number} };

has version     => is => 'ro', lazy => 1, 
    default  => sub { shift->_parsed->{version} };

has quality     => is => 'ro', lazy => 1, 
    default  => sub { shift->_parsed->{quality} || 'standard' };

has size     => is => 'ro', lazy => 1,
    default  => sub { shift->_parsed->{size} };

sub _parse {
    my $title = shift->title;

    $title =~ /^\s*
      (?<name>.+?)
      \s+
      (?<chapter>
        S (?<season>\d+) E (?<number>\d+)
       |(?<season>\d+) x (?<number>\d+)
       |(?<number>\d+) of (?<total>\d+)
      )
      \s+
      (?<version>
        ((?<quality>\d+p)\s+)?
        (?<team>.*?)
      )
      (?: 
        \s+
        \((?<size> 
          \d+ 
          [^\)]+
        )\) 
      )?
    \s*$/xi;

    return {
        name    => $+{name} || $title,
        chapter => $+{chapter},
        number  => $+{number} +0,
        season  => ($+{season}||0) +0,
        total   => ($+{total}||0) +0,
        version => $+{version} || '',
        quality => $+{quality} || 'standard',
        team    => $+{team},
        size    => $+{size}
    };
}

1;

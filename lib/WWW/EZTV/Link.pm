package WWW::EZTV::Link;
use Moose;
with 'WWW::EZTV::UA';

# ABSTRACT: EZTV episode link

has url => is => 'ro', isa => 'Str', required => 1;

1;

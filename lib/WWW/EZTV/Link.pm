package WWW::EZTV::Link;
use Moose;
with 'WWW::EZTV::UA';

# ABSTRACT: Episode link

=attr url

Link address

=cut
has url => is => 'ro', isa => 'Str', required => 1;


=attr type

Link type. It can be:

 - magnet
 - torrent
 - torrent-redirect (URL that do html/js redirect to a torrent file)
 - direct

=cut
has type => is => 'ro', lazy => 1, builder => '_guess_type';

sub _guess_type {
    my $self = shift;

    if ( $self->url =~ /magnet:/ ) {
        return 'magnet';
    }
    elsif ( $self->url =~ /\.torrent$/ ) {
        return 'torrent';
    }
    elsif ( $self->url =~ /bt-chat.com/ ) {
        return 'torrent-redirect';
    }

    return 'direct';
}
1;

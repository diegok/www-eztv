package WWW::EZTV::UA;
use Moose::Role;
use Mojo::UserAgent;

# ABSTRACT: User agent for EZTV scrapper.

has ua  => ( is => 'ro', lazy => 1, default => sub { $EZTV::Global::UA || ($EZTV::Global::UA = Mojo::UserAgent->new) } );

=method get_response
=cut
sub get_response {
    my ($self, $url) = (shift, shift);

    my $tx = $self->ua->get( $url );
    if ( my $res = $tx->success ) {
        return $res;
    }
    else {
        my ($err, $code) = $tx->error;
        my $message = shift || 'User agent error';
        confess sprintf('%s: %s (%s)', $message, $err, $code||'no error code');
    }
}

1;

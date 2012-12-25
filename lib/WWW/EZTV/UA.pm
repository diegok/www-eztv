package WWW::EZTV::UA;
use Moose::Role;
use Mojo::UserAgent;

has ua  => ( is => 'ro', lazy => 1, default => sub { $EZTV::Global::UA || ($EZTV::Global::UA = Mojo::UserAgent->new) } );

sub get_response {
    my ($self, $url) = (shift, shift);

    my $tx = $self->ua->get( $url );
    if ( my $res = $tx->success ) {
        return $res;
    }
    else {
        my ($err, $code) = $tx->error;
        my $message = shift || 'User agent error';
        die "$message: $err ($code)";
    }
}

1;

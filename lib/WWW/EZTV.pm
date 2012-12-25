package WWW::EZTV;
use Moose;
with 'WWW::EZTV::UA';
use WWW::EZTV::Show;

has url       => ( is => 'ro', lazy => 1, default => sub { Mojo::URL->new('http://eztv.it/') } );
has url_shows => ( is => 'ro', lazy => 1, default => sub { shift->url->clone->path('/showlist/') } );
has shows => 
    is      => 'ro',
    lazy    => 1,
    default => \&build_shows,
    handles => {
        find_show    => 'first',
        has_shows    => 'size',
    };

sub build_shows {
    my $self = shift;

    $self->get_response( $self->url_shows )->dom->find('table.forum_header_border tr[name="hover"]')->map(sub {
        my $tr = shift;
        my $link = $tr->at('td:nth-child(1) a');
        WWW::EZTV::Show->new(
            title  => $link->all_text,
            url    => $self->url->clone->path($link->attrs('href')),
            status => lc($tr->at('td:nth-child(2)')->all_text),
            rating => $tr->at('td:nth-child(3)')->all_text
        );
    });
}

1;

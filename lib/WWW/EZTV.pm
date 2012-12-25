package WWW::EZTV;
use Moose;
with 'WWW::EZTV::UA';
use WWW::EZTV::Show;

# ABSTRACT: EZTV scrapper

has url       => ( is => 'ro', lazy => 1, default => sub { Mojo::URL->new('http://eztv.it/') } );
has url_shows => ( is => 'ro', lazy => 1, default => sub { shift->url->clone->path('/showlist/') } );

has shows => 
    is      => 'ro',
    lazy    => 1,
    builder => '_build_shows',
    handles => {
        find_show    => 'first',
        has_shows    => 'size',
    };

sub _build_shows {
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

=head1 SYNOPSIS

First create a WWW::EZTV object to navigate.

    use WWW::EZTV;

    my $eztv = WWW::EZTV->new;

    my $show = $eztv->find_show(sub{ $_->name =~ /Walking dead/i });

    my $episode = $show->find_episode(sub{ 
        $_->season == 3 && 
        $_->number == 8 && 
        $_->quality eq 'standard' 
    });

=attr url
EZTV URL.
=cut

=attr url_shows
EZTV shows URL.
=cut

=attr shows
L<Mojo::Collection> of L<WWW::EZTV::Show> objects.
=cut

=attr has_shows
How many shows exists.
=cut

=method find_show
Find first L<WWW::EZTV::Show> object matching the given criteria. 
This method accept an anon function.
=cut

1;

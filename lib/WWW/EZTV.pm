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
            url    => $self->url->clone->path($link->attr('href')),
            status => lc($tr->at('td:nth-child(2)')->all_text),
            rating => $tr->at('td:nth-child(3)')->all_text
        );
    });
}

1;

=head1 SYNOPSIS

    use WWW::EZTV;
    use v5.10;

    my $eztv = WWW::EZTV->new;

    # Find one show
    my $show = $eztv->find_show(sub{ $_->name =~ /Walking dead/i });

    # Find one episode
    my $episode = $show->find_episode(sub{ 
        $_->season == 3 && 
        $_->number == 8 && 
        $_->quality eq 'standard' 
    });

    # Get first torrent url for this episode
    say $episode->find_link(sub{ $_->type eq 'torrent' })->url;

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

=head1 BUGS

This is an early release, so probable there are plenty of bugs around.
If you found one, please report it on RT or at the github repo:

L<https://github.com/diegok/www-eztv>

Pull requests are also very welcomed, but please include tests demostrating
what you've fixed.

=cut


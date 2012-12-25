package WWW::EZTV::Show;
use Moose;
with 'WWW::EZTV::UA';
use WWW::EZTV::Link;
use WWW::EZTV::Episode;

# ABSTRACT: EZTV show object

has title    => is => 'ro', isa => 'Str', required => 1;
has name     => is => 'ro', lazy => 1, default => \&_name;
has year     => is => 'ro', lazy => 1, default => \&_year;
has url      => is => 'ro', isa => 'Mojo::URL', required => 1;
has status   => is => 'ro', isa => 'Str', required => 1;
has rating   => is => 'ro', isa => 'Int', default => sub {0};
has episodes => 
    is      => 'ro',
    lazy    => 1,
    builder => '_build_episodes',
    handles => {
        find_episode => 'first',
        has_episodes => 'size',
    };

sub _build_episodes {
    my $self = shift;
    $self->get_response($self->url)->dom->find('table.forum_header_noborder tr[name="hover"]')->map(sub{
        my $tr = shift;
        my $a  = $tr->at('td:nth-child(2) a');

        WWW::EZTV::Episode->new(
            title    => $a->attrs('title'),
            url      => $self->url->clone->path($a->attrs('href')),
            links    => $tr->find('td:nth-child(3) a')->map(sub{
                WWW::EZTV::Link->new( url => shift->attrs('href') )
            }),
            released => $tr->at('td:nth-child(4)')->all_text,
            show     => $self
        );
    });
}

sub _name {
    my $self = shift;
    my $name = $self->title;

    # Chasers War on Everything, The
    if ( $name =~ /^(.+),\s*([^,]+)$/ ) { $name = "$2 $1" }

    # Remove year: Castle (2009)
    $name =~ s/\s* \(\d{4}\) \s*/ /x;

    # Trim and cleanup spaces
    $self->_cleanup_str($name);
}

sub _year {
    my $self = shift;
    if ( $self->title =~ /\((\d{4})\)/ ) {
        return $1;
    }
}

sub _cleanup_str {
    my $str = pop;
    $str =~ s/^\s+|\s+$//g;
    $str =~ s/\s+/ /g;
    $str;
}

1;

=attr title
=cut

=attr name
=cut

=attr year
=cut

=attr url
=cut

=attr status
=cut

=attr rating
=cut

=attr episodes
Collection of episodes fetched for this show.
=cut

=attr has_episodes
How many episodes has this show.
=cut

=method find_episode
Find first L<WWW::EZTV::Episode> object matching the given criteria. 
This method accept an anon function.
=cut


package MusicBrainz::Server::Edit::Role::MergeSubscription;
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Data::Utils qw( model_to_type );

requires 'subscription_model', '_entity_ids', 'do_merge', '_merge_model';

around do_merge => sub {
    my ($orig, $self, @args) = @_;

    my $editors = $self->subscription_model->delete($self->_old_ids);
    my $entities = $self->c->model($self->_merge_model)->get_by_ids($self->_old_ids);

    $self->$orig(@args);

    $self->subscription_model->log_deletions(
        $self->id,
        map +{
            editor => $_->{editor},
            gid => $entities->{ $_->{ model_to_type($self->_merge_model) } }->gid
        }, @$editors
    );
};

1;

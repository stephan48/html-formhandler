package HTML::FormHandler::Fields;

use Moose::Role;
use Carp;
use UNIVERSAL::require;
use Class::Inspector;

=head1 NAME

HTML::FormHandler::Fields - role to build field array

=head1 SYNOPSIS

These are internal methods to build the field array. Probably
not useful to users. 

=head2 fields

The field definitions as built from the field_list and the 'has_field'
declarations. This is a MooseX::AttributeHelpers::Collection::Array, 
and provides clear_fields, add_field, remove_last_field, num_fields,
has_fields, and set_field_at methods.

=cut

has 'field_list' => ( isa => 'HashRef', is => 'rw', default => sub { {} } );

=head2 field_name_space

Use to set the name space used to locate fields that 
start with a "+", as: "+MetaText". Fields without a "+" are loaded
from the "HTML::FormHandler::Field" name space. If 'field_name_space'
is not set, then field types with a "+" must be the complete package
name.

=cut

has 'field_name_space' => (
   isa     => 'Str|Undef',
   is      => 'rw',
   default => '',
);
   
=head2 fields

The field definitions as built from the field_list and the 'has_field'
declarations. This is a MooseX::AttributeHelpers::Collection::Array, 
and provides clear_fields, add_field, remove_last_field, num_fields,
has_fields, and set_field_at methods.

=cut

has 'node' => ( isa => 'HTML::FormHandler::Node', is => 'rw',
     lazy => 1,
     builder => 'build_node',
     handles => [ 'fields', 'add_field', 'clear_fields',
        'remove_last_field', 'num_fields', 'has_fields',
        'set_field_at', 'field_index', 'field',
        'fields_validate', 
        'parent', 
        'form_name', 'language_handle'
     ],
);

has 'is_top_level' => ( isa => 'Bool', is => 'rw', default => 0 );

sub build_node
{
   my $self = shift;

   my $meta_field_list = $self->_build_meta_field_list; 

   return HTML::FormHandler::Node->new( 
      field_list => $self->field_list,
      meta_field_list => $meta_field_list,
      field_name_space => $self->field_name_space,
      parent => $self,
      is_top_level => $self->is_top_level,
      form_name => $self->form_name,
      language_handle => $self->language_handle,
   );
}

sub _build_meta_field_list
{
   my $self = shift;
   my @field_list;
   foreach my $sc ( reverse $self->meta->linearized_isa )
   {
      my $meta = $sc->meta;
      foreach my $role ( $meta->calculate_all_roles )
      {
         if ( $role->can('field_list') && defined $role->field_list )
         {
            push @field_list, @{$role->field_list};
         }
      }
      if ( $meta->can('field_list') && defined $meta->field_list )
      {
         push @field_list, @{$meta->field_list};
      }
   }
   return \@field_list if scalar @field_list;
}

no Moose::Role;
1;

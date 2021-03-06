package Net::Braintree::Result;
use Moose;
use Hash::Inflator;
use Net::Braintree::Util;
use Net::Braintree::ValidationErrorCollection;
use Net::Braintree::CreditCardVerification;

my $meta = __PACKAGE__->meta;

my $response_objects = {
  address => "Net::Braintree::Address",
  credit_card => "Net::Braintree::CreditCard",
  customer => "Net::Braintree::Customer",
  merchant_account => "Net::Braintree::MerchantAccount",
  settlement_batch_summary => "Net::Braintree::SettlementBatchSummary",
  subscription => "Net::Braintree::Subscription",
  transaction => "Net::Braintree::Transaction",
};

has response => ( is => 'ro' );

while(my($type, $class) = each(%$response_objects)) {
  $meta->add_method($type, sub {
    my $self = shift;
    my $response = $self->response->{'api_error_response'} || $self->response;
    if (!$response->{$type}) {
      return undef;
    }
    return $class->new($response->{$type});
  })
}

sub is_success {
  my $self = shift;
  return 1 unless $self->response->{'api_error_response'};
  return 0;
}

sub api_error_response {
  my $self = shift;
  return $self->response->{'api_error_response'};
}

sub message {
  my $self = shift;
  return $self->api_error_response->{'message'} if $self->api_error_response;
  return "";
}

sub errors {
  my $self = shift;
  return Net::Braintree::ValidationErrorCollection->new($self->api_error_response->{errors});
}

sub credit_card_verification {
  my $self = shift;
  return Net::Braintree::CreditCardVerification->new($self->api_error_response->{verification});
}

1;

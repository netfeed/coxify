package Coxify::Image;

use strict;

use Coxify::Db;
use Coxify::Model::Image;

sub date_list {
  my %p = @_;

  my ($sql, $binds) = Coxify::Model::Image::Manager->get_objects_sql(
    select => ['created_date', 'COUNT(t1.created_date)'],
    where => [
      active => 1,
      created_date => { gt_le => [ $p{from}, $p{to} ] }
    ],
    sort_by => 'created_date ASC',
    group_by => 'created_date',
    $p{limit} ? (limit => $p{limit}) : (),
  );

  my $db = new Coxify::Db();
  my $dbh = $db->dbh;
  my $query = $dbh->selectall_arrayref($sql, {}, @{ $binds });

  my @dates = ();
  for my $date (@{ $query }) {
    push @dates, {
      date => $date->[0],
      count => $date->[1],
      url => join("/", "/image", split(/-/, $date->[0])),
    };
  }

  @dates = reverse @dates;

  return \@dates;
}

sub year_list {
  my ($year) = @_;

  my @where = (
    active => 1,
  );

  if ($year) {
    my $from_date = new DateTime(year => $year, month => '01', day => '01');
    my $to_date = DateTime->last_day_of_month(year => $year, month => '12');
    push @where, (created_date => { gt_le => [ $from_date, $to_date ] });
  }

  my ($sql, $binds) = Coxify::Model::Image::Manager->get_objects_sql(
    select => [ "date_trunc('month', t1.created_date)",  "count(date_trunc('month', t1.created_date))" ], 
    where => \@where,
    sort_by => "date_Trunc('month', t1.created_date) ASC",
    group_by => "date_trunc('month', t1.created_date)",
  );

  my $db = new Coxify::Db();
  my $dbh = $db->dbh;
  my $query = $dbh->selectall_arrayref($sql, {}, @{ $binds });

  my @year = ();
  for my $obj (@{ $query }) {
    my ($year, $month, $day) = split(/-/, $obj->[0]);
    my $date = new DateTime(year => $year, month => $month);
    push @year, {
      month => $date,
      count => $obj->[1],
      url => join("/", "/image", $year, $month),
    };   
  }

  @year = reverse sort({ $a->{month} <=> $b->{month} } @year);

  return \@year;
}

1;
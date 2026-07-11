///|
pub(all) struct CronExpr {
  minutes : Array[Int]
  hours : Array[Int]
  days_of_month : Array[Int]
  has_last_day_of_month : Bool
  day_of_month_wildcard : Bool
  months : Array[Int]
  days_of_week : Array[Int]
  day_of_week_wildcard : Bool
}

///|
pub(all) enum CronError {
  InvalidFormat(String)
  OutOfBounds(String)
} derive(Debug, Eq)

///|
pub impl Show for CronError with fn to_string(self : CronError) -> String {
  match self {
    InvalidFormat(message) => "Invalid cron expression: \{message}"
    OutOfBounds(message) => "Cron value out of bounds: \{message}"
  }
}

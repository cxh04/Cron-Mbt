///|
fn abs_int(value : Int) -> Int {
  if value < 0 {
    -value
  } else {
    value
  }
}

///|
pub fn DateTime::validate(self : DateTime) -> Result[Unit, CronError] {
  if self.year < 1 || self.year > 9999 {
    return Err(OutOfBounds("year must be between 1 and 9999"))
  }
  if self.month < 1 || self.month > 12 {
    return Err(OutOfBounds("month must be between 1 and 12"))
  }
  let dim = days_in_month(self.year, self.month)
  if self.day < 1 || self.day > dim {
    return Err(OutOfBounds("day is outside the selected month"))
  }
  if self.hour < 0 || self.hour > 23 {
    return Err(OutOfBounds("hour must be between 0 and 23"))
  }
  if self.minute < 0 || self.minute > 59 {
    return Err(OutOfBounds("minute must be between 0 and 59"))
  }
  Ok(())
}

///|
pub fn DateTime::format(self : DateTime) -> String {
  let month = if self.month < 10 {
    "0" + self.month.to_string()
  } else {
    self.month.to_string()
  }
  let day = if self.day < 10 {
    "0" + self.day.to_string()
  } else {
    self.day.to_string()
  }
  let hour = if self.hour < 10 {
    "0" + self.hour.to_string()
  } else {
    self.hour.to_string()
  }
  let minute = if self.minute < 10 {
    "0" + self.minute.to_string()
  } else {
    self.minute.to_string()
  }
  "\{self.year}-\{month}-\{day} \{hour}:\{minute}"
}

///|
pub fn DateTime::compare(self : DateTime, other : DateTime) -> Int {
  if self.year != other.year {
    if self.year < other.year {
      -1
    } else {
      1
    }
  } else if self.month != other.month {
    if self.month < other.month {
      -1
    } else {
      1
    }
  } else if self.day != other.day {
    if self.day < other.day {
      -1
    } else {
      1
    }
  } else if self.hour != other.hour {
    if self.hour < other.hour {
      -1
    } else {
      1
    }
  } else if self.minute != other.minute {
    if self.minute < other.minute {
      -1
    } else {
      1
    }
  } else {
    0
  }
}

///|
pub fn DateTime::add_minutes(
  self : DateTime,
  amount : Int,
) -> Result[DateTime, CronError] {
  match self.validate() {
    Ok(_) => ()
    Err(err) => return Err(err)
  }
  let result = { ..self }
  let mut remaining = abs_int(amount)
  let direction = if amount < 0 { -1 } else { 1 }
  while remaining > 0 {
    result.minute += direction
    if result.minute > 59 {
      result.minute = 0
      result.hour += 1
    } else if result.minute < 0 {
      result.minute = 59
      result.hour -= 1
    }
    if result.hour > 23 {
      result.hour = 0
      result.day += 1
    } else if result.hour < 0 {
      result.hour = 23
      result.day -= 1
    }
    if result.day > days_in_month(result.year, result.month) {
      result.day = 1
      result.month += 1
    } else if result.day < 1 {
      result.month -= 1
      if result.month < 1 {
        result.month = 12
        result.year -= 1
      }
      result.day = days_in_month(result.year, result.month)
    }
    if result.month > 12 {
      result.month = 1
      result.year += 1
    }
    if result.year < 1 || result.year > 9999 {
      return Err(OutOfBounds("datetime arithmetic left supported year range"))
    }
    remaining -= 1
  }
  Ok(result)
}

///|
pub fn DateTime::is_before(self : DateTime, other : DateTime) -> Bool {
  self.compare(other) < 0
}

///|
pub fn DateTime::is_after(self : DateTime, other : DateTime) -> Bool {
  self.compare(other) > 0
}

///|
pub fn DateTime::same_minute(self : DateTime, other : DateTime) -> Bool {
  self.compare(other) == 0
}

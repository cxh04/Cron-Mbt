///|
/// Ordered cron stages for practical ETL, billing, and deployment workflows.
pub(all) struct WorkflowStage {
  stage : String
  expression : CronExpr
  order : Int
  enabled : Bool
}

///|
pub fn WorkflowStage::new(
  stage : String,
  expression : String,
  order : Int,
) -> Result[WorkflowStage, CronError] {
  if stage.trim().is_empty() {
    return Err(InvalidFormat("workflow stage cannot be empty"))
  }
  if order < 0 {
    return Err(OutOfBounds("workflow stage order cannot be negative"))
  }
  let parsed = match parse(expression) {
    Ok(value) => value
    Err(err) => return Err(err)
  }
  Ok({ stage, expression: parsed, order, enabled: true })
}

///|
pub fn WorkflowStage::pause(self : WorkflowStage) -> WorkflowStage {
  { ..self, enabled: false }
}

///|
pub fn WorkflowStage::enable(self : WorkflowStage) -> WorkflowStage {
  { ..self, enabled: true }
}

///|
pub fn WorkflowStage::next(
  self : WorkflowStage,
  current : DateTime,
) -> Result[DateTime, CronError] {
  if !self.enabled {
    return Err(InvalidFormat("workflow stage is paused"))
  }
  self.expression.next_time(current)
}

///|
pub(all) struct WorkflowRun {
  stage : String
  scheduled_at : DateTime
  order : Int
}

///|
pub(all) struct Workflow {
  name : String
  stages : Array[WorkflowStage]
}

///|
pub fn Workflow::new(name : String) -> Workflow {
  { name, stages: [] }
}

///|
pub fn Workflow::add_stage(
  self : Workflow,
  stage : WorkflowStage,
) -> Result[Unit, CronError] {
  for existing in self.stages {
    if existing.stage == stage.stage {
      return Err(InvalidFormat("workflow stage names must be unique"))
    }
  }
  self.stages.push(stage)
  self.stages.sort_by(fn(a, b) { a.order - b.order })
  Ok(())
}

///|
pub fn Workflow::remove_stage(self : Workflow, name : String) -> Bool {
  for index, stage in self.stages {
    if stage.stage == name {
      let _ = self.stages.remove(index)
      return true
    }
  }
  false
}

///|
pub fn Workflow::stage_count(self : Workflow) -> Int {
  self.stages.length()
}

///|
pub fn Workflow::validate(self : Workflow) -> Bool {
  if self.name.trim().is_empty() {
    return false
  }
  let mut previous = -1
  for stage in self.stages {
    if stage.order < previous || stage.expression.minutes.is_empty() {
      return false
    }
    previous = stage.order
  }
  true
}

///|
pub fn Workflow::preview(
  self : Workflow,
  current : DateTime,
  limit : Int,
) -> Result[Array[WorkflowRun], CronError] {
  if limit < 0 {
    return Err(InvalidFormat("workflow limit cannot be negative"))
  }
  let result : Array[WorkflowRun] = []
  for stage in self.stages {
    if result.length() >= limit {
      break
    }
    match stage.next(current) {
      Ok(value) =>
        result.push({
          stage: stage.stage,
          scheduled_at: value,
          order: stage.order,
        })
      Err(_) => ()
    }
  }
  Ok(result)
}

///|
pub fn Workflow::due_stages(
  self : Workflow,
  current : DateTime,
) -> Result[Array[WorkflowRun], CronError] {
  let result : Array[WorkflowRun] = []
  for stage in self.stages {
    if stage.enabled && stage.expression.matches_datetime(current) {
      result.push({
        stage: stage.stage,
        scheduled_at: current,
        order: stage.order,
      })
    }
  }
  Ok(result)
}

///|
pub fn Workflow::next_stage(
  self : Workflow,
  current : DateTime,
) -> Result[WorkflowRun, CronError] {
  let preview = match self.preview(current, 1) {
    Ok(values) => values
    Err(err) => return Err(err)
  }
  if preview.is_empty() {
    Err(InvalidFormat("workflow has no enabled stage"))
  } else {
    Ok(preview[0])
  }
}

///|
pub fn Workflow::render(self : Workflow) -> String {
  let lines : Array[String] = ["workflow=\{self.name}"]
  for stage in self.stages {
    let state = if stage.enabled { "enabled" } else { "paused" }
    lines.push(
      "\{stage.order}:\{stage.stage}:\{state}:\{stage.expression.canonical()}",
    )
  }
  lines.join("\n")
}

///|
pub fn Workflow::stage_names(self : Workflow) -> Array[String] {
  self.stages.map(fn(stage) { stage.stage })
}

///|
test "workflow engine validates and previews ordered stages" {
  let workflow = Workflow::new("morning-pipeline")
  workflow
  .add_stage(WorkflowStage::new("extract", "0 8 * * 1-5", 10).unwrap())
  .unwrap()
  workflow
  .add_stage(WorkflowStage::new("transform", "15 8 * * 1-5", 20).unwrap())
  .unwrap()
  workflow
  .add_stage(WorkflowStage::new("publish", "30 8 * * 1-5", 30).unwrap())
  .unwrap()
  assert_eq(workflow.stage_count(), 3)
  assert_true(workflow.validate())
  let now : DateTime = { year: 2026, month: 8, day: 10, hour: 7, minute: 0 }
  let preview = workflow.preview(now, 5).unwrap()
  assert_eq(preview.length(), 3)
  assert_eq(preview[0].stage, "extract")
  assert_true(workflow.render().contains("morning-pipeline"))
}

///|
test "workflow engine reports overdue stages and rejects duplicates" {
  let workflow = Workflow::new("billing")
  workflow
  .add_stage(WorkflowStage::new("charge", "0 9 * * *", 1).unwrap())
  .unwrap()
  assert_true(
    workflow.add_stage(WorkflowStage::new("charge", "0 10 * * *", 2).unwrap())
    is Err(_),
  )
  let now : DateTime = { year: 2026, month: 8, day: 10, hour: 9, minute: 0 }
  let due = workflow.due_stages(now).unwrap()
  assert_eq(due.length(), 1)
  assert_eq(due[0].stage, "charge")
}

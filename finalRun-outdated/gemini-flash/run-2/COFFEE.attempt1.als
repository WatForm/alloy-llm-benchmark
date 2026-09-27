", and 
    only "HeatFlow" "decreases" "HEAT_OF_CUP".

    However, if a "ThermalThing" 
    "touches" either "Cup" or "Coffee" 
    when "HEAT_OF_COFFEE" is "greaterThan" "HEAT_OF_CUP" 
    then
    the "state" of "HEAT_OF_COFFEE" must be "DECREASING",
    the "state" of "TEMPERATURE_OF_COFFEE" must be "DECREASING",
    the "state" of "HEAT_OF_CUP" must be "INCREASING",
    and "state" of "TEMPERATURE_OF_CUP" must be "INCREASING",
    only "HeatFlow" "increases" "HEAT_OF_CUP", and 
    only "HeatFlow" decreases "HEAT_OF_COFFEE".
    ```

    Look at the sentences:
    Notice:
    - `"QuallitativeState"` with two 'l's! This exact spelling must be used: `QuallitativeState`.
    - `"increases"` and `"decreases"`:
      "Every "Process" is associated with exactly one "increases" "HEAT" and with exactly one "decreases" "HEAT"."
      Wait! In Process:
      `increases: one HEAT`
      `decreases: one HEAT`
      Wait, but later:
      `the "HeatFlow" does not "increases" the "HEAT_OF_CUP"`
      Wait! If `increases` is a relation from Process to HEAT, why does it say:
      `the "HeatFlow" does not "increases" the "HEAT_OF_CUP"`?
      Wait, if `increases: one HEAT`, then HeatFlow MUST increase exactly one HEAT!
      Wait! Look at:
      `the "HeatFlow" does not "increases" the "HEAT_OF_CUP", the "HeatFlow" does not "increases" the "HEAT_OF_COFFEE"`
      If HeatFlow increases neither HEAT_OF_CUP nor HEAT_OF_COFFEE, and HEAT only contains HEAT_OF_CUP and HEAT_OF_COFFEE, then HeatFlow increases NOTHING!
      BUT "Every "Process" is associated with exactly one "increases" "HEAT""!
      How can HeatFlow be associated with exactly one HEAT if it increases neither HEAT_OF_CUP nor HEAT_OF_COFFEE?!
      WAIT!
      LOOK AT NAD'S COMMENT AGAIN!
      `// NAD: this seems to be impossible b/c there must be a "HeatFlow" element`
      `If a "ThermalThing" "touches" neither "Cup" nor "Coffee", then there is no "greaterThan" relationship at all and there is no "HeatFlow".`
      Wait! Why did NAD write:
      `// NAD: this seems to be impossible b/c there must be
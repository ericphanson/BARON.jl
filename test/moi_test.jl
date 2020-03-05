module MOITests

using BARON
using Test

using MathOptInterface
const MOI = MathOptInterface
const MOIT = MOI.Test
const MOIU = MOI.Utilities
const MOIB = MOI.Bridges

const optimizer = BARON.Optimizer(PrLevel=0)
const caching_optimizer = MOIU.CachingOptimizer(MOIU.Model{Float64}(), BARON.Optimizer(PrLevel=0));

# const optimizer = MOI.Bridges.full_bridge_optimizer(BARON.Optimizer(PrLevel=0), Float64)

# TODO: test infeasibility certificates, duals.

@testset "Unit" begin
    # bridged = MOIB.full_bridge_optimizer(
    #     Ipopt.Optimizer(print_level=0, fixed_variable_treatment="make_constraint"),
    #     Float64)
    # A number of test cases are excluded because loadfromstring! works only
    # if the solver supports variable and constraint names.
    exclude = ["delete_variable", # Deleting not supported.
               "delete_variables", # Deleting not supported.
               "getvariable", # Variable names not supported.
               "solve_zero_one_with_bounds_1", # Variable names not supported.
               "solve_zero_one_with_bounds_2", # Variable names not supported.
               "solve_zero_one_with_bounds_3", # Variable names not supported.
               "getconstraint", # Constraint names not suported.
               "variablenames", # Variable names not supported.
               "solve_with_upperbound", # loadfromstring!
               "solve_with_lowerbound", # loadfromstring!
               "solve_integer_edge_cases", # loadfromstring!
               "solve_affine_lessthan", # loadfromstring!
               "solve_affine_greaterthan", # loadfromstring!
               "solve_affine_equalto", # loadfromstring!
               "solve_affine_interval", # loadfromstring!
               "get_objective_function", # Function getters not supported.
               "solve_constant_obj",  # loadfromstring!
               "solve_blank_obj", # loadfromstring!
               "solve_singlevariable_obj", # loadfromstring!
               "solve_objbound_edge_cases", # ObjectiveBound not supported.
               "solve_affine_deletion_edge_cases", # Deleting not supported.
               "solve_unbounded_model", # `NORM_LIMIT`
               "number_threads", # NumberOfThreads not supported
               "delete_nonnegative_variables", # get ConstraintFunction n/a.
               "update_dimension_nonnegative_variables", # get ConstraintFunction n/a.
               "delete_soc_variables", # VectorOfVar. in SOC not supported
               "solve_result_index", # DualObjectiveValue not supported
               ]
    # MOIT.unittest(bridged, config, exclude)
end

MOI.empty!(optimizer)

@testset "MOI Continuous Linear" begin
    config = MOIT.TestConfig(atol=1e-5, rtol=1e-4, infeas_certificates=false, duals=false)
    excluded = String[
        "linear7", # vector constraints
        "linear8b", # certificate provided in this case (result count is 1)
        "linear8c", # should be unbounded below, returns "Preprocessing found feasible solution with value -.200000000000E+052"
        "linear15", # vector constraints
        "partial_start" # TODO
    ]
    # MOIT.partial_start_test(optimizer, config)
    MOIT.contlineartest(caching_optimizer, config, excluded)
    MOIT.linear8btest(caching_optimizer, MOIT.TestConfig(atol=1e-5, rtol=1e-4, infeas_certificates=true, duals=false))
end

MOI.empty!(optimizer)

@testset "MOI Integer Linear" begin
    config = MOIT.TestConfig(atol=1e-5, rtol=1e-4, infeas_certificates=false, duals=false)
    excluded = String[
        "int2", # SOS1
        "indicator1", # ACTIVATE_ON_ONE
        "indicator2", # ACTIVATE_ON_ONE
        "indicator3", # ACTIVATE_ON_ONE
        "indicator4", # ACTIVATE_ON_ONE
    ]
    MOIT.intlineartest(caching_optimizer, config, excluded)
end

MOI.empty!(optimizer)

@testset "MOI Continuous Quadratic" begin
    # TODO: rather high tolerances
    config = MOIT.TestConfig(atol=1e-3, rtol=1e-3, infeas_certificates=false, duals=false)
    excluded = String[
        "qcp1", # vector constraints
    ]
    MOIT.contquadratictest(caching_optimizer, config, excluded)
end

MOI.empty!(optimizer)
bridged = MOIB.full_bridge_optimizer(optimizer, Float64)

@testset "MOI Nonlinear" begin
    config = MOIT.TestConfig(atol=1e-5, rtol=1e-4, infeas_certificates=false, duals=false)
    MOIT.nlptest(bridged, config)
end

end # module

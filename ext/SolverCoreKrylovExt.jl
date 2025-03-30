module SolverCoreKrylovExt

using LinearAlgebra
using SolverCore
using Krylov
import Krylov.FloatOrComplex

# Krylov methods
for (workspace, args, def_args, optargs, def_optargs, kwargs, def_kwargs) in [
  (:LsmrSolver     , Krylov.args_lsmr      , Krylov.def_args_lsmr      , ()                       , ()                           , Krylov.kwargs_lsmr      , Krylov.def_kwargs_lsmr      )
  (:CgsSolver      , Krylov.args_cgs       , Krylov.def_args_cgs       , Krylov.optargs_cgs       , Krylov.def_optargs_cgs       , Krylov.kwargs_cgs       , Krylov.def_kwargs_cgs       )
  (:UsymlqSolver   , Krylov.args_usymlq    , Krylov.def_args_usymlq    , Krylov.optargs_usymlq    , Krylov.def_optargs_usymlq    , Krylov.kwargs_usymlq    , Krylov.def_kwargs_usymlq    )
  (:LnlqSolver     , Krylov.args_lnlq      , Krylov.def_args_lnlq      , ()                       , ()                           , Krylov.kwargs_lnlq      , Krylov.def_kwargs_lnlq      )
  (:BicgstabSolver , Krylov.args_bicgstab  , Krylov.def_args_bicgstab  , Krylov.optargs_bicgstab  , Krylov.def_optargs_bicgstab  , Krylov.kwargs_bicgstab  , Krylov.def_kwargs_bicgstab  )
  (:CrlsSolver     , Krylov.args_crls      , Krylov.def_args_crls      , ()                       , ()                           , Krylov.kwargs_crls      , Krylov.def_kwargs_crls      )
  (:LsqrSolver     , Krylov.args_lsqr      , Krylov.def_args_lsqr      , ()                       , ()                           , Krylov.kwargs_lsqr      , Krylov.def_kwargs_lsqr      )
  (:MinresSolver   , Krylov.args_minres    , Krylov.def_args_minres    , Krylov.optargs_minres    , Krylov.def_optargs_minres    , Krylov.kwargs_minres    , Krylov.def_kwargs_minres    )
  (:MinaresSolver  , Krylov.args_minares   , Krylov.def_args_minares   , Krylov.optargs_minares   , Krylov.def_optargs_minares   , Krylov.kwargs_minares   , Krylov.def_kwargs_minares   )
  (:CgneSolver     , Krylov.args_cgne      , Krylov.def_args_cgne      , ()                       , ()                           , Krylov.kwargs_cgne      , Krylov.def_kwargs_cgne      )
  (:DqgmresSolver  , Krylov.args_dqgmres   , Krylov.def_args_dqgmres   , Krylov.optargs_dqgmres   , Krylov.def_optargs_dqgmres   , Krylov.kwargs_dqgmres   , Krylov.def_kwargs_dqgmres   )
  (:SymmlqSolver   , Krylov.args_symmlq    , Krylov.def_args_symmlq    , Krylov.optargs_symmlq    , Krylov.def_optargs_symmlq    , Krylov.kwargs_symmlq    , Krylov.def_kwargs_symmlq    )
  (:TrimrSolver    , Krylov.args_trimr     , Krylov.def_args_trimr     , Krylov.optargs_trimr     , Krylov.def_optargs_trimr     , Krylov.kwargs_trimr     , Krylov.def_kwargs_trimr     )
  (:UsymqrSolver   , Krylov.args_usymqr    , Krylov.def_args_usymqr    , Krylov.optargs_usymqr    , Krylov.def_optargs_usymqr    , Krylov.kwargs_usymqr    , Krylov.def_kwargs_usymqr    )
  (:BilqrSolver    , Krylov.args_bilqr     , Krylov.def_args_bilqr     , Krylov.optargs_bilqr     , Krylov.def_optargs_bilqr     , Krylov.kwargs_bilqr     , Krylov.def_kwargs_bilqr     )
  (:CrSolver       , Krylov.args_cr        , Krylov.def_args_cr        , Krylov.optargs_cr        , Krylov.def_optargs_cr        , Krylov.kwargs_cr        , Krylov.def_kwargs_cr        )
  (:CarSolver      , Krylov.args_car       , Krylov.def_args_car       , Krylov.optargs_car       , Krylov.def_optargs_car       , Krylov.kwargs_car       , Krylov.def_kwargs_car       )
  (:CraigmrSolver  , Krylov.args_craigmr   , Krylov.def_args_craigmr   , ()                       , ()                           , Krylov.kwargs_craigmr   , Krylov.def_kwargs_craigmr   )
  (:TricgSolver    , Krylov.args_tricg     , Krylov.def_args_tricg     , Krylov.optargs_tricg     , Krylov.def_optargs_tricg     , Krylov.kwargs_tricg     , Krylov.def_kwargs_tricg     )
  (:CraigSolver    , Krylov.args_craig     , Krylov.def_args_craig     , ()                       , ()                           , Krylov.kwargs_craig     , Krylov.def_kwargs_craig     )
  (:DiomSolver     , Krylov.args_diom      , Krylov.def_args_diom      , Krylov.optargs_diom      , Krylov.def_optargs_diom      , Krylov.kwargs_diom      , Krylov.def_kwargs_diom      )
  (:LslqSolver     , Krylov.args_lslq      , Krylov.def_args_lslq      , ()                       , ()                           , Krylov.kwargs_lslq      , Krylov.def_kwargs_lslq      )
  (:TrilqrSolver   , Krylov.args_trilqr    , Krylov.def_args_trilqr    , Krylov.optargs_trilqr    , Krylov.def_optargs_trilqr    , Krylov.kwargs_trilqr    , Krylov.def_kwargs_trilqr    )
  (:CrmrSolver     , Krylov.args_crmr      , Krylov.def_args_crmr      , ()                       , ()                           , Krylov.kwargs_crmr      , Krylov.def_kwargs_crmr      )
  (:CgSolver       , Krylov.args_cg        , Krylov.def_args_cg        , Krylov.optargs_cg        , Krylov.def_optargs_cg        , Krylov.kwargs_cg        , Krylov.def_kwargs_cg        )
  (:CglsSolver     , Krylov.args_cgls      , Krylov.def_args_cgls      , ()                       , ()                           , Krylov.kwargs_cgls      , Krylov.def_kwargs_cgls      )
  (:CgLanczosSolver, Krylov.args_cg_lanczos, Krylov.def_args_cg_lanczos, Krylov.optargs_cg_lanczos, Krylov.def_optargs_cg_lanczos, Krylov.kwargs_cg_lanczos, Krylov.def_kwargs_cg_lanczos)
  (:BilqSolver     , Krylov.args_bilq      , Krylov.def_args_bilq      , Krylov.optargs_bilq      , Krylov.def_optargs_bilq      , Krylov.kwargs_bilq      , Krylov.def_kwargs_bilq      )
  (:MinresQlpSolver, Krylov.args_minres_qlp, Krylov.def_args_minres_qlp, Krylov.optargs_minres_qlp, Krylov.def_optargs_minres_qlp, Krylov.kwargs_minres_qlp, Krylov.def_kwargs_minres_qlp)
  (:QmrSolver      , Krylov.args_qmr       , Krylov.def_args_qmr       , Krylov.optargs_qmr       , Krylov.def_optargs_qmr       , Krylov.kwargs_qmr       , Krylov.def_kwargs_qmr       )
  (:GmresSolver    , Krylov.args_gmres     , Krylov.def_args_gmres     , Krylov.optargs_gmres     , Krylov.def_optargs_gmres     , Krylov.kwargs_gmres     , Krylov.def_kwargs_gmres     )
  (:FgmresSolver   , Krylov.args_fgmres    , Krylov.def_args_fgmres    , Krylov.optargs_fgmres    , Krylov.def_optargs_fgmres    , Krylov.kwargs_fgmres    , Krylov.def_kwargs_fgmres    )
  (:FomSolver      , Krylov.args_fom       , Krylov.def_args_fom       , Krylov.optargs_fom       , Krylov.def_optargs_fom       , Krylov.kwargs_fom       , Krylov.def_kwargs_fom       )
  (:GpmrSolver     , Krylov.args_gpmr      , Krylov.def_args_gpmr      , Krylov.optargs_gpmr      , Krylov.def_optargs_gpmr      , Krylov.kwargs_gpmr      , Krylov.def_kwargs_gpmr      )
  (:CgLanczosShiftSolver  , Krylov.args_cg_lanczos_shift  , Krylov.def_args_cg_lanczos_shift      , (), (), Krylov.kwargs_cg_lanczos_shift  , Krylov.def_kwargs_cg_lanczos_shift  )
  (:CglsLanczosShiftSolver, Krylov.args_cgls_lanczos_shift, Krylov.def_args_cgls_lanczos_shift    , (), (), Krylov.kwargs_cgls_lanczos_shift, Krylov.def_kwargs_cgls_lanczos_shift)
]
  ## In-place
  @eval SolverCore.solve!(solver :: $workspace{T,FC,S}, $(def_args...); $(def_kwargs...)) where {T <: AbstractFloat, FC <: FloatOrComplex{T}, S <: AbstractVector{FC}} = krylov_solve!(solver, $(args...); $(kwargs...))
  @eval begin
    if !isempty($optargs)
      SolverCore.solve!(solver :: $workspace{T,FC,S}, $(def_args...), $(def_optargs...); $(def_kwargs...)) where {T <: AbstractFloat, FC <: FloatOrComplex{T}, S <: AbstractVector{FC}} = krylov_solve!(solver, $(args...), $(optargs...); $(kwargs...))
    end
  end
end

# Block-Krylov methods
for (workspace, args, def_args, optargs, def_optargs, kwargs, def_kwargs) in [
  (:BlockMinresSolver, Krylov.args_block_minres, Krylov.def_args_block_minres, Krylov.optargs_block_minres, Krylov.def_optargs_block_minres, Krylov.kwargs_block_minres, Krylov.def_kwargs_block_minres)
  (:BlockGmresSolver , Krylov.args_block_gmres , Krylov.def_args_block_gmres , Krylov.optargs_block_gmres , Krylov.def_optargs_block_gmres , Krylov.kwargs_block_gmres , Krylov.def_kwargs_block_gmres )
]
  ## In-place
  @eval SolverCore.solve!(solver :: $workspace{T,FC,SV,SM}, $(def_args...); $(def_kwargs...)) where {T <: AbstractFloat, FC <: FloatOrComplex{T}, SV <: AbstractVector{FC}, SM <: AbstractMatrix{FC}} = krylov_solve!(solver, $(args...); $(kwargs...))
  @eval begin
    if !isempty($optargs)
      SolverCore.solve!(solver :: $workspace{T,FC,SV,SM}, $(def_args...), $(def_optargs...); $(def_kwargs...)) where {T <: AbstractFloat, FC <: FloatOrComplex{T}, SV <: AbstractVector{FC}, SM <: AbstractMatrix{FC}} = krylov_solve!(solver, $(args...), $(optargs...); $(kwargs...))
    end
  end
end

end

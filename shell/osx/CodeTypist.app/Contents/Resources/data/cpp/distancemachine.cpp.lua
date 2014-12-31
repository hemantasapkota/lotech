return [=[
#ifndef _DISTANCE_MACHINE_H__
#define _DISTANCE_MACHINE_H__

#include <shogun/lib/config.h>

#include <shogun/lib/common.h>
#include <shogun/machine/Machine.h>

namespace shogun
{
        class CDistance;
        class CFeatures;
        class CMulticlassLabels;

class CDistanceMachine : public CMachine
{
  public:
    CDistanceMachine();

    virtual ~CDistanceMachine();
    void set_distance(CDistance* d);
    CDistance* get_distance() const;
    void distances_lhs(float64_t* result,int32_t idx_a1,int32_t idx_a2,int32_t
    idx_b);
    void distances_rhs(float64_t* result,int32_t idx_b1,int32_t idx_b2,int32_t
    idx_a);
    virtual const char* get_name() const { return ''DistanceMachine''; }
    virtual CMulticlassLabels* apply_multiclass(CFeatures* data=NULL);
    virtual float64_t apply_one(int32_t num);

  protected:
    virtual void store_model_features();
    static void* run_distance_thread_lhs(void* p);
    static void* run_distance_thread_rhs(void* p);

  private:
    void init();

  protected:
    CDistance* distance;
};
}
#endif
]=]

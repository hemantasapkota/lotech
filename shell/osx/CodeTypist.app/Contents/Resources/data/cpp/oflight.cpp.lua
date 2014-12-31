return [=[
#pragma once

#include ''ofNode.h''
#include ''ofColor.h''
#include ''of3dGraphics.h''
#include ''ofTypes.h''

enum ofLightType {
        OF_LIGHT_POINT=0,
        OF_LIGHT_DIRECTIONAL=1,
        OF_LIGHT_SPOT=2,
        OF_LIGHT_AREA=3
};

void ofEnableLighting();
void ofDisableLighting();
void ofEnableSeparateSpecularLight();
void ofDisableSeparateSpecularLight();
bool ofGetLightingEnabled();
void ofSetSmoothLighting(bool b);
void ofSetGlobalAmbientColor(const ofFloatColor& c);
const ofFloatColor & ofGetGlobalAmbientColor();

class ofLight : public ofNode {
public:
  ofLight();

  void setup();
  void enable();
  void disable();
  bool getIsEnabled() const;

  void setDirectional();
  bool getIsDirectional() const;

  void setSpotlight( float spotCutOff=45.f, float exponent=0.f );
  bool getIsSpotlight() const;
  void setSpotlightCutOff( float spotCutOff );
  float getSpotlightCutOff() const;
  void setSpotConcentration( float exponent );
  float getSpotConcentration() const;

  void setPointLight();
  bool getIsPointLight() const;
  void setAttenuation( float constant=1.f, float linear=0.f, float quadratic=0.f );
  float getAttenuationConstant() const;
  float getAttenuationLinear() const;
  float getAttenuationQuadratic() const;

  void setAreaLight(float width, float height);
  bool getIsAreaLight() const;

  int getType() const;

  void setAmbientColor(const ofFloatColor& c);
  void setDiffuseColor(const ofFloatColor& c);
  void setSpecularColor(const ofFloatColor& c);

  ofFloatColor getAmbientColor() const;
  ofFloatColor getDiffuseColor() const;
  ofFloatColor getSpecularColor() const;

  int getLightID() const;

  void customDraw();

  class Data{
  public:
      Data();
      ~Data();

      ofFloatColor ambientColor;
      ofFloatColor diffuseColor;
      ofFloatColor specularColor;

      float attenuation_constant;
      float attenuation_linear;
      float attenuation_quadratic;

      ofLightType lightType;

      int glIndex;
      int isEnabled;
      float spotCutOff;
      float exponent;
      ofVec4f position;
      ofVec3f direction;

      float width;
      float height;
      ofVec3f up;
      ofVec3f right;
  };

private:
  shared_ptr<Data> data;

  virtual void onPositionChanged();
  virtual void onOrientationChanged();
};

vector<weak_ptr<ofLight::Data> > & ofLightsData();
]=]

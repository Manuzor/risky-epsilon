#include "stdafx.h"
#include "gpp/gameComponents/renderComponent.h"
#include "gep/globalManager.h"
#include "gep/interfaces/renderer.h"
#include "gep/interfaces/logging.h"


#include "gep/interfaces/scripting.h"
#include "gep/interfaces/animation.h"

#include "gep/ArrayPtr.h"
#include "gep/math3d/mat4.h"

#include <array>


gpp::RenderComponent::RenderComponent():
    Component(),
    m_path(),
    m_pModel(nullptr),
    m_extractionCallbackId(0),
    m_bones()
{

}

gpp::RenderComponent::~RenderComponent()
{
    m_pModel = nullptr;
}

void gpp::RenderComponent::initalize()
{
    if(m_path.empty())
    {
        g_globalManager.getLogging()->logError("Render Component's path on GameObject %s hasn't been set!", m_pParentGameObject->getName().c_str());
        GEP_ASSERT(false);
    }
    else
    {
        m_pModel = g_globalManager.getRenderer()->loadModel(m_path.c_str());
    }

    if (m_state != State::Initial) { return; } // User already set a different state.
    setState(State::Active);
}

void gpp::RenderComponent::update(float elapsedMS)
{
}

void gpp::RenderComponent::destroy()
{
    g_globalManager.getRendererExtractor()->deregisterExtractionCallback(m_extractionCallbackId);
}

void gpp::RenderComponent::extract(gep::IRendererExtractor& extractor)
{
    m_pModel->extract(extractor, m_pParentGameObject->getTransformationMatrix());
}


void gpp::RenderComponent::applyBoneTransformations(const gep::ArrayPtr<gep::BoneTransform>& transformations)
{
    m_bones.clear();
    m_bones.reserve(transformations.length());

    int i =0;
    for (auto& trans :transformations)
    {
        gep::mat4 transformation = gep::mat4::translationMatrix(trans.translation);
        transformation.setRotationPart(trans.rotation.toMat3());
        m_bones.append(transformation);
    }
    m_pModel->setBones(m_bones.toArray());
}

void gpp::RenderComponent::setState(State::Enum state)
{
    if (m_state == state) { return; }

    m_state = state;

    switch (state)
    {
    case State::Active:
        {
            if (m_extractionCallbackId.id == 0)
            {
                m_extractionCallbackId = g_globalManager.getRendererExtractor()->registerExtractionCallback(
                    std::bind(&RenderComponent::extract,this,std::placeholders::_1));
            }
            else
            {
                g_globalManager.getLogging()->logWarning(
                    "You should not set your render component's state to Active twice in a row.");
            }
        }
        break;
    case State::Inactive:
        {
            if (m_extractionCallbackId.id != 0)
            {
                g_globalManager.getRendererExtractor()->deregisterExtractionCallback(m_extractionCallbackId);
                m_extractionCallbackId.id = 0;
            }
            else
            {
                g_globalManager.getLogging()->logWarning(
                    "You should not set your render component's state to Inactive twice in a row.");
            }
        }
        break;
    default:
        GEP_ASSERT(false, "Invalid State!");
        break;
    }
}

#pragma once

#include "gpp/gameObjectSystem.h"
#include "gep/math3d/vec3.h"
#include "gep/math3d/quaternion.h"
#include "gep/interfaces/physics.h"
#include "gep/interfaces/physics/characterController.h"

#include "gep/interfaces/scripting.h"

namespace gpp
{
    class CharacterComponent : public Component, public gep::ITransform
    {
    public:
        CharacterComponent();
        virtual ~CharacterComponent();
        
        virtual void initalize();

        virtual void update(float elapsedMS);

        virtual void destroy();

        virtual void setPosition(const gep::vec3& pos );
        virtual void setRotation(const gep::Quaternion& rot );
        virtual void setScale(const gep::vec3& scale );

        virtual gep::vec3 getPosition() override;
        virtual gep::Quaternion getRotation() override;
        virtual gep::vec3 getScale() override;
        virtual gep::mat4 getTransformationMatrix() override;
        virtual gep::vec3 getViewDirection() override;
        virtual gep::vec3 getUpDirection() override;
        virtual gep::vec3 getRightDirection() override;

        virtual void setBaseOrientation(const gep::Quaternion& viewDir) override;
        virtual void setBaseViewDirection(const gep::vec3& direction) override;
        void createCharacterRigidBody(gep::CharacterRigidBodyCInfo cinfo);
        
        void move(const gep::vec3& delta);
        
        inline gep::ICharacterRigidBody* getCharacterRigidBody(){ return m_pCharacterRigidBody.get(); }
        
        inline const gep::ICharacterRigidBody* getCharacterRigidBody() const { return m_pCharacterRigidBody.get(); }
       
        inline gep::IWorld* getWorld() { return m_pWorld; }
       
        inline const gep::IWorld* getWorld() const { return m_pWorld; }
        
        inline void setWorld(gep::IWorld* world) { m_pWorld = world; }

        LUA_BIND_REFERENCE_TYPE_BEGIN
            LUA_BIND_FUNCTION(createCharacterRigidBody)
        LUA_BIND_REFERENCE_TYPE_END;

    private:
        gep::vec3 m_position;
        gep::Quaternion m_rotation;
        mutable gep::SmartPtr<gep::ICharacterRigidBody> m_pCharacterRigidBody;
        gep::IWorld* m_pWorld;
        gep::Quaternion m_baseOrientation;
    };

    template<>
    struct ComponentMetaInfo<CharacterComponent>
    {
        static const char* name(){ return "CharacterComponent"; }
        static const gep::int32 initializationPriority() { return 0; }
        static const gep::int32 updatePriority() { return 0; }
        static CharacterComponent* create(){return new CharacterComponent(); }
    };
}

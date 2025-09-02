/****************************************************************************
** Meta object code from reading C++ file 'ListModel.h'
**
** Created by: The Qt Meta Object Compiler version 69 (Qt 6.9.1)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../src/model/ListModel.h"
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>

#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'ListModel.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 69
#error "This file was generated using the moc from 6.9.1. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

#ifndef Q_CONSTINIT
#define Q_CONSTINIT
#endif

QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
QT_WARNING_DISABLE_GCC("-Wuseless-cast")
namespace {
struct qt_meta_tag_ZN9ListModelE_t { };
} // unnamed namespace

template <>
constexpr inline auto ListModel::qt_create_metaobjectdata<qt_meta_tag_ZN9ListModelE_t>()
{
    namespace QMC = QtMocConstants;
    QtMocHelpers::StringRefStorage qt_stringData {
        "ListModel",
        "countChanged",
        "",
        "addGame",
        "name",
        "path",
        "remove",
        "index",
        "count",
        "getGameName",
        "getGamePath"
    };

    QtMocHelpers::UintData qt_methods {
        // Signal 'countChanged'
        QtMocHelpers::SignalData<void()>(1, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'addGame'
        QtMocHelpers::MethodData<void(const QString&, const QString&)>(3, 2, QMC::AccessPublic, QMetaType::Void, { {
                                                                                                                     { QMetaType::QString, 4 },
                                                                                                                     { QMetaType::QString, 5 },
                                                                                                                 } }),
        // Method 'remove'
        QtMocHelpers::MethodData<void(int)>(6, 2, QMC::AccessPublic, QMetaType::Void, { {
                                                                                          { QMetaType::Int, 7 },
                                                                                      } }),
        // Method 'count'
        QtMocHelpers::MethodData<int() const>(8, 2, QMC::AccessPublic, QMetaType::Int),
        // Method 'getGameName'
        QtMocHelpers::MethodData<QString(int) const>(9, 2, QMC::AccessPublic, QMetaType::QString, { {
                                                                                                      { QMetaType::Int, 7 },
                                                                                                  } }),
        // Method 'getGamePath'
        QtMocHelpers::MethodData<QString(int) const>(10, 2, QMC::AccessPublic, QMetaType::QString, { {
                                                                                                       { QMetaType::Int, 7 },
                                                                                                   } }),
    };
    QtMocHelpers::UintData qt_properties {
        // property 'count'
        QtMocHelpers::PropertyData<int>(8, QMetaType::Int, QMC::DefaultPropertyFlags, 0),
    };
    QtMocHelpers::UintData qt_enums {};
    return QtMocHelpers::metaObjectData<ListModel, qt_meta_tag_ZN9ListModelE_t>(QMC::MetaObjectFlag {}, qt_stringData,
        qt_methods, qt_properties, qt_enums);
}
Q_CONSTINIT const QMetaObject ListModel::staticMetaObject = { { QMetaObject::SuperData::link<QAbstractListModel::staticMetaObject>(),
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN9ListModelE_t>.stringdata,
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN9ListModelE_t>.data,
    qt_static_metacall,
    nullptr,
    qt_staticMetaObjectRelocatingContent<qt_meta_tag_ZN9ListModelE_t>.metaTypes,
    nullptr } };

void ListModel::qt_static_metacall(QObject* _o, QMetaObject::Call _c, int _id, void** _a)
{
    auto* _t = static_cast<ListModel*>(_o);
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0:
            _t->countChanged();
            break;
        case 1:
            _t->addItem((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])), (*reinterpret_cast<std::add_pointer_t<QString>>(_a[2])));
            break;
        case 2:
            _t->remove((*reinterpret_cast<std::add_pointer_t<int>>(_a[1])));
            break;
        case 3: {
            int _r = _t->count();
            if (_a[0])
                *reinterpret_cast<int*>(_a[0]) = std::move(_r);
        } break;
        case 4: {
            QString _r = _t->getGameName((*reinterpret_cast<std::add_pointer_t<int>>(_a[1])));
            if (_a[0])
                *reinterpret_cast<QString*>(_a[0]) = std::move(_r);
        } break;
        case 5: {
            QString _r = _t->getGamePath((*reinterpret_cast<std::add_pointer_t<int>>(_a[1])));
            if (_a[0])
                *reinterpret_cast<QString*>(_a[0]) = std::move(_r);
        } break;
        default:;
        }
    }
    if (_c == QMetaObject::IndexOfMethod) {
        if (QtMocHelpers::indexOfMethod<void (ListModel::*)()>(_a, &ListModel::countChanged, 0))
            return;
    }
    if (_c == QMetaObject::ReadProperty) {
        void* _v = _a[0];
        switch (_id) {
        case 0:
            *reinterpret_cast<int*>(_v) = _t->count();
            break;
        default:
            break;
        }
    }
}

const QMetaObject* ListModel::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void* ListModel::qt_metacast(const char* _clname)
{
    if (!_clname)
        return nullptr;
    if (!strcmp(_clname, qt_staticMetaObjectStaticContent<qt_meta_tag_ZN9ListModelE_t>.strings))
        return static_cast<void*>(this);
    return QAbstractListModel::qt_metacast(_clname);
}

int ListModel::qt_metacall(QMetaObject::Call _c, int _id, void** _a)
{
    _id = QAbstractListModel::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 6)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 6;
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 6)
            *reinterpret_cast<QMetaType*>(_a[0]) = QMetaType();
        _id -= 6;
    }
    if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
        || _c == QMetaObject::ResetProperty || _c == QMetaObject::BindableProperty
        || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 1;
    }
    return _id;
}

// SIGNAL 0
void ListModel::countChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}
QT_WARNING_POP
